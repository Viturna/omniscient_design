class StudiosController < ApplicationController
  include ContributionManageable
  include RecaptchaHelper

  before_action :set_studio, only: %i[show edit update destroy cancel validate reject]
  before_action :authenticate_user!, only: %i[new create edit update destroy cancel validate]
  before_action :check_certified, only: %i[validate destroy reject]
  before_action :check_edit_permission, only: %i[edit update]

  def show
    @domaines = @studio.domaines
    if user_signed_in?
      unless @studio.validation || current_user.admin? || @studio.user == current_user || current_user.certified?
        redirect_to root_path, alert: I18n.t('studio.access.denied', default: 'Accès refusé')
      end
      @lists = current_user.lists
    else
      redirect_to root_path, alert: I18n.t('studio.access.denied', default: 'Accès refusé') unless @studio.validation
      @lists = []
    end

    image_url = @studio.studio_images.first&.file&.attached? ? view_context.url_for(@studio.studio_images.first.file) : nil
    set_meta_tags(
      title: "#{@studio.nom} : Histoire et créations du studio",
      description: view_context.truncate(@studio.presentation_generale, length: 160),
      og: { image: image_url },
      twitter: { image: image_url }
    )

    @saved_studio_ids = if user_signed_in?
                          current_user.saved_studios.pluck(:id)
                        else
                          []
                        end
  end

  def new
    @studio = Studio.new
    10.times { @studio.designer_studios.build }
    3.times do |i|
      @studio.studio_images.build(position: i + 1)
    end
    @current_page = 'add_elements'
  end

  def edit
    @current_page = 'add_elements'
    existing_images = @studio.studio_images.count

    (3 - existing_images).times do |i|
      max_pos = @studio.studio_images.map(&:position).compact.max || 0
      @studio.studio_images.build(position: max_pos + i + 1)
    end
    (10 - @studio.designer_studios.count).times { @studio.designer_studios.build }
    @country_1, @country_2, @country_3 = @studio.country_ids[0..2]
  end

  def create
    @studio = Studio.new(studio_params)
    @studio.user = current_user
    token = params[:recaptcha_token]

    if verify_recaptcha(token) && @studio.save
      Rails.cache.delete('linkify_keywords_list')
      update_suivi_references_emises(current_user)
      create_notification(@studio)
      create_author_notification(@studio)
      flash[:success] = 'Nous avons bien reçu ta contribution ! Elle sera traitée dans les plus brefs délais.'
      redirect_to @studio
    else
      3.times do |i|
        @studio.studio_images.build(position: i + 1)
      end
      flash.now[:alert] = I18n.t('studio.create.failure', default: 'Erreur lors de la création')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @studio.update(studio_params)
      notify_admin_of_update(@studio) if !@studio.validation && @studio.user == current_user
      flash[:success] = I18n.t('studio.update.success', default: 'Studio mis à jour')
      redirect_to @studio
    else
      flash.now[:alert] = I18n.t('studio.update.failure', default: 'Erreur lors de la mise à jour')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @studio.destroy
      handle_destroy_success(@studio)
    else
      redirect_to validation_path, alert: I18n.t('studio.destroy.error', default: 'Erreur lors de la suppression')
    end
  end

  def reject
    params[:rejection_reason].presence || I18n.t('studio.reject.no_comment',
                                                 default: 'Aucun commentaire')

    @studio.studios_domaines.delete_all if @studio.respond_to?(:studios_domaines)

    if @studio.destroy
      create_rejection_notification(@studio)
      update_suivi_references_refusees(@studio.user)
      redirect_to validation_path, notice: I18n.t('studio.reject.success', default: 'Studio rejeté')
    else
      redirect_to validation_path, alert: I18n.t('studio.reject.failure', default: 'Erreur lors du rejet')
    end
  end

  def cancel
    if user_signed_in? && (current_user.admin? || @studio.user_id == current_user.id)
      @studio.destroy

      update_suivi_references_refusees(@studio.user) if @studio.user

      flash[:notice] = 'Ta contribution a été annulée avec succès.'
    else
      flash[:alert] = "Tu n'as pas l'autorisation d'annuler cette contribution."
    end
    redirect_to add_elements_path
  end

  def validate
    if @studio.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@studio)
      update_suivi_references_validees(@studio.user)
      GamificationService.new(@studio.user).check_contributor
      redirect_to validation_path,
                  notice: I18n.t('studio.validate.success', name: @studio.nom, default: 'Studio validé')
    else
      redirect_to validation_path, alert: I18n.t('studio.validate.failure', default: 'Erreur de validation')
    end
  end

  def check_existence
    studio = Studio.where('LOWER(nom) = ?', params[:nom].to_s.downcase.strip).first

    if studio
      render json: {
        exists: true,
        validated: studio.validation,
        edit_path: user_signed_in? && studio.user_id == current_user.id ? edit_studio_path(studio) : nil
      }
    else
      render json: { exists: false }
    end
  end

  def save_modal
    @studio = Studio.friendly.find(params[:slug])
    @lists = current_user.lists
    render layout: false
  end

  private

  def check_edit_permission
    return if current_user.admin? || current_user.certified? || (@studio.user == current_user && !@studio.validated?)

    redirect_to root_path, alert: I18n.t('studio.access.denied', default: 'Accès refusé')
  end










  def set_studio
    @studio = Studio.includes(:countries).friendly.find(params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to studios_path, alert: 'Studio introuvable.'
  end

  def studio_params
    params.require(:studio).permit(
      :nom,
      :date_creation,
      :date_fin,
      :presentation_generale,
      :formation_et_influences,
      :style_ou_philosophie,
      :creations_majeures,
      :heritage_et_impact,
      :image,
      :recaptcha_token,
      domaine_ids: [],
      country_ids: [],
      source: [],
      studio_images_attributes: %i[
        id
        file
        credit
        _destroy
        position
      ],
      designer_studios_attributes: %i[
        id
        designer_id
        date_entree
        date_sortie
        _destroy
      ]
    )
  end
end
