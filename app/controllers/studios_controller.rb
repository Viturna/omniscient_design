class StudiosController < ApplicationController
  include RecaptchaHelper

  before_action :set_studio, only: %i[show edit update destroy cancel validate reject]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :cancel, :validate]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]

  def show
    @domaines = @studio.domaines
    if user_signed_in?
      unless @studio.validation || current_user.admin? || @studio.user == current_user || current_user.certified?
        redirect_to root_path, alert: I18n.t('studio.access.denied', default: "Accès refusé")
      end
      @lists = current_user.lists
    else
      unless @studio.validation
        redirect_to root_path, alert: I18n.t('studio.access.denied', default: "Accès refusé")
      end
      @lists = []
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
      Rails.cache.delete("linkify_keywords_list")
      update_suivi_references_emises(current_user)
      create_notification(@studio)
      flash[:success] = I18n.t('studio.create.success', default: "Studio créé avec succès")
      redirect_to @studio
    else
      3.times do |i|
        @studio.studio_images.build(position: i + 1)
      end
      flash.now[:alert] = I18n.t('studio.create.failure', default: "Erreur lors de la création")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @studio.update(studio_params)
      flash[:success] = I18n.t('studio.update.success', default: "Studio mis à jour")
      redirect_to @studio
    else
      flash.now[:alert] = I18n.t('studio.update.failure', default: "Erreur lors de la mise à jour")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @studio.destroy
      handle_destroy_success(@studio)
    else
      redirect_to validation_path, alert: I18n.t('studio.destroy.error', default: "Erreur lors de la suppression")
    end
  end

  def reject
    rejection_reason = params[:rejection_reason].presence || I18n.t('studio.reject.no_comment', default: "Aucun commentaire")
    
    @studio.studios_domaines.delete_all if @studio.respond_to?(:studios_domaines)

    if @studio.destroy
      create_rejection_notification(@studio)
      update_suivi_references_refusees(@studio.user)
      redirect_to validation_path, notice: I18n.t('studio.reject.success', default: "Studio rejeté")
    else
      redirect_to validation_path, alert: I18n.t('studio.reject.failure', default: "Erreur lors du rejet")
    end
  end

  def cancel
    if user_signed_in? && (current_user.admin? || @studio.user_id == current_user.id)
      @studio.destroy
    
      update_suivi_references_refusees(@studio.user) if @studio.user
      
      flash[:notice] = "La contribution a été annulée avec succès."
    else
      flash[:alert] = "Vous n'avez pas l'autorisation d'annuler cette contribution."
    end
    redirect_to add_elements_path
  end

  def validate
    if @studio.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@studio)
      update_suivi_references_validees(@studio.user)
      redirect_to validation_path, notice: I18n.t('studio.validate.success', name: @studio.nom, default: "Studio validé")
    else
      redirect_to validation_path, alert: I18n.t('studio.validate.failure', default: "Erreur de validation")
    end
  end

  def check_existence
    studio = Studio.where("LOWER(nom) = ?", params[:nom].to_s.downcase.strip).first

    if studio
      render json: { 
        exists: true, 
        validated: studio.validation,
        edit_path: (user_signed_in? && studio.user_id == current_user.id) ? edit_studio_path(studio) : nil 
      }
    else
      render json: { exists: false }
    end
  end

  private

  def handle_destroy_success(studio)
    redirect_to validation_path, notice: I18n.t('studio.destroy.success', name: studio.nom, default: "Studio supprimé")
  end

  def update_suivi_references_emises(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_emises)
  end

  def update_suivi_references_validees(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_validees)
  end

  def update_suivi_references_refusees(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment!(:nb_references_refusees)
  end

  def create_notification(studio)
    title = "Nouvelle proposition"
    message = I18n.t('notifications.new_studio', name: studio.nom, default: "Nouveau studio à valider : #{studio.nom}")
    
    User.where("role = ? OR certified = ?", 'admin', true).each do |user|
      Notification.create(
        user_id: user.id, 
        notifiable: studio, 
        title: title,
        message: message
      )
    end
  end

  def create_validation_notification(studio)
    return unless studio.user_id
    
    title = "Fiche validée"
    message = I18n.t('notifications.studio_validated', name: studio.nom, default: "Votre studio #{studio.nom} a été validé.")
    
    Notification.create(
      user_id: studio.user_id, 
      notifiable: studio, 
      title: title,
      message: message
    )
  end

  def create_rejection_notification(studio)
     return unless studio.user_id
     
     title = "Fiche refusée"
     message = I18n.t('notifications.studio_rejected', name: studio.nom, default: "Votre studio #{studio.nom} a été refusé.")
     
     Notification.create(
       user_id: studio.user_id, 
       notifiable: studio,
       title: title,
       message: message
     ) 
  end

  def set_studio
    @studio = Studio.friendly.find(params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to studios_path, alert: "Studio introuvable."
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
      studio_images_attributes: [
        :id, 
        :file, 
        :credit, 
        :_destroy,
        :position
      ],
      designer_studios_attributes: [
        :id, 
        :designer_id, 
        :date_entree, 
        :date_sortie, 
        :_destroy
      ]
    )
  end
end