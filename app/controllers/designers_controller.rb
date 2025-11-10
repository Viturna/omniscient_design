class DesignersController < ApplicationController
  include RecaptchaHelper

  before_action :set_designer, only: %i[show edit update destroy cancel validate reject]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :cancel, :validate]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]

  def index
    @designers = Designer.where(validation: true).order("RANDOM()").limit(2)
    @current_page = 'accueil'
  end

  def load_more
    offset = params[:offset].to_i
    limit = 2
    loaded_ids = params[:loaded_ids]&.split(',')&.map(&:to_i) || []

    @designers = Designer.where(validation: true)
                         .where.not(id: loaded_ids)
                         .order("RANDOM()")
                         .offset(offset)
                         .limit(limit)

    render partial: 'designers/card', collection: @designers, as: :card, locals: { class_name: 'card' }
  end

  def show
    @domaines = @designer.domaines
    if user_signed_in?
      unless @designer.validation || current_user.admin? || @designer.user == current_user || current_user.certified?
        redirect_to root_path, alert: I18n.t('designer.access.denied')
      end
      @lists = current_user.lists
    else
      unless @designer.validation
        redirect_to root_path, alert: I18n.t('designer.access.denied')
      end
      @lists = []
    end
  end

  def new
    @designer = Designer.new
    @current_page = 'add_elements'
    # AJOUT : Construit 3 champs d'images vides pour le formulaire
    3.times { @designer.designer_images.build }
  end

  def edit
    @current_page = 'add_elements'
    # AJOUT : Construit des champs d'images supplémentaires jusqu'à 3
    (3 - @designer.designer_images.count).times { @designer.designer_images.build }
  end

  def create
    @designer = Designer.new(designer_params)
    @designer.user = current_user
    token = params[:recaptcha_token]

    if verify_recaptcha(token) && @designer.save
      update_suivi_references_emises(current_user)
      create_notification(@designer)
      flash[:success] = I18n.t('designer.create.success')
      redirect_to @designer
    else
      @countries = Country.order(:country)
      flash.now[:alert] = I18n.t('designer.create.failure')
      # Assure que les champs d'image sont reconstruits en cas d'erreur
      (3 - @designer.designer_images.count).times { @designer.designer_images.build }
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @designer.update(designer_params)
      flash[:success] = I18n.t('designer.update.success')
      redirect_to @designer
    else
      @countries = Country.order(:country)
      flash.now[:alert] = I18n.t('designer.update.failure')
      # Assure que les champs d'image sont reconstruits en cas d'erreur
      (3 - @designer.designer_images.count).times { @designer.designer_images.build }
      render :edit, status: :unprocessable_entity
    end
  end

  # ... (actions destroy, reject, cancel, validate, check_existence inchangées) ...
  def destroy
    @designer = Designer.find_by(slug: params[:slug])
    if @designer
      handle_destroy(@designer, I18n.t('designer.destroy.success', name: @designer.nom_designer))
    else
      redirect_to validation_path, alert: I18n.t('designer.not_found')
    end
  end

  def reject
    rejection_reason = params[:rejection_reason].presence || I18n.t('designer.reject.no_comment')
    @designer = Designer.friendly.find_by(slug: params[:slug])

    unless @designer
      redirect_to validation_path, alert: I18n.t('designer.not_found') and return
    end

    ActiveRecord::Base.transaction do
      RejectedDesigner.create!(
        nom: @designer.nom,
        prenom: @designer.prenom,
        user: @designer.user,
        reason: rejection_reason
      )
      @designer.designers_domaines.delete_all if @designer.respond_to?(:designers_domaines)
      @designer.designer_countries.delete_all if @designer.respond_to?(:designer_countries)
      @designer.designers_oeuvres.delete_all if @designer.respond_to?(:designers_oeuvres)
      @designer.update!(rejection_reason: rejection_reason, validation: false)

      if @designer.user.present?
        handle_destroy(@designer, I18n.t('designer.reject.success'))
      else
        Rails.logger.warn("Le designer #{@designer.id} n'a pas d'utilisateur associé pour la notification de rejet.")
        redirect_to validation_path, notice: I18n.t('designer.reject.success') and return
      end
    rescue => e
      Rails.logger.error("Erreur rejet designer : #{e.message}")
      redirect_to validation_path, alert: I18n.t('designer.reject.failure')
    end
  end

  def cancel
    if user_signed_in?
      if current_user.admin? || @designer.user_id == current_user.id
        update_suivi_references_refusees(@designer.user)
        @designer.destroy!
        flash[:notice] = I18n.t('designer.cancel.success')
        redirect_to designers_path
      else
        flash[:alert] = I18n.t('designer.cancel.denied')
        redirect_to designers_path
      end
    end
  end

  def validate
    if @designer.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@designer)
      update_suivi_references_validees(@designer.user)
      redirect_to validation_path, notice: I18n.t('designer.validate.success', name: @designer.nom_designer)
    else
      redirect_to validation_path, alert: I18n.t('designer.validate.failure')
    end
  end

  def check_existence
    designer = Designer.find_by("LOWER(prenom) = ? AND LOWER(nom) = ?", params[:prenom].downcase, params[:nom].downcase)

    if designer
      render json: { exists: true, edit_path: designer.validated? ? nil : edit_designer_path(designer) }
    else
      render json: { exists: false }
    end
  end


  private

  def handle_destroy(designer, success_message)
    if designer.destroy
      create_rejection_notification(designer)
      update_suivi_references_refusees(designer.user)
  
      respond_to do |format|
        format.html { redirect_to validation_path, notice: success_message }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to validation_path, alert: "Une erreur est survenue lors de la suppression du designer." }
        format.json { render json: designer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_suivi_references_emises(user)
    suivi = user.suivis.first_or_create
    suivi.increment(:nb_references_emises)
    suivi.save
  end

  def update_suivi_references_validees(user)
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment(:nb_references_validees)
    suivi.save
  end

  def update_suivi_references_refusees(user)
    suivi = user.suivis.first_or_create
    suivi.increment(:nb_references_refusees)
    suivi.save
  end
  
  def create_notification(designer)
    message = t('notifications.new_designer', name: designer.nom_designer)
    recipients = User.where("role = ? OR certified = ?", 'admin', true)
    recipients.each do |user|
      Notification.create(user_id: user.id, notifiable: designer, message: message)
    end
  end

  def create_validation_notification(designer)
    message = t('notifications.designer_validated', name: designer.nom_designer)
    if designer.user_id.present?
      Notification.create(user_id: designer.user_id, notifiable: designer, message: message)
    else
      Notification.create(notifiable: designer, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error(t('notifications.error_creation', error: e.message))
  end

  def create_rejection_notification(designer)
    if designer.user_id.present?
      message = t('notifications.designer_rejected', name: designer.nom_designer)
      Notification.create(user_id: designer.user_id, notifiable: designer, message: message)
    else
      Rails.logger.error(t('notifications.no_user_for_rejection_designer', designer_id: designer.id))
    end
  end

  def set_designer
    @designer = Designer.friendly.find(params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to validation_path, alert: "Designer n'a pas été trouvée."
  end

  def designer_params
    params.require(:designer).permit(
      :nom,
      :prenom,
      :date_naissance,
      :date_deces,
      :presentation_generale,
      :formation_et_influences,
      :style_ou_philosophie,
      :creations_majeures,
      :heritage_et_impact,
      :image, # C'est l'ancien champ image URL, on le garde
      :recaptcha_token,
      domaine_ids: [],
      country_ids: [],
      source: [],
      # AJOUT : Permet les attributs pour les images uploadées
      designer_images_attributes: [:id, :file, :credit, :_destroy]
    )
  end
end