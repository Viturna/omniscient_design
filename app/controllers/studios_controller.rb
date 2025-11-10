class StudiosController < ApplicationController
  include RecaptchaHelper

  before_action :set_studio, only: %i[show edit update destroy cancel validate reject]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :cancel, :validate]
  # Adaptez check_certified si besoin (ex: check_admin_or_certified comme vu avant)
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]

  def index
    @studios = Studio.where(validation: true).order("RANDOM()").limit(2)
    # Adaptez @current_page si besoin
    @current_page = 'accueil'
  end

  def load_more
    offset = params[:offset].to_i
    limit = 2
    loaded_ids = params[:loaded_ids]&.split(',')&.map(&:to_i) || []

    @studios = Studio.where(validation: true)
                     .where.not(id: loaded_ids)
                     .order("RANDOM()")
                     .offset(offset)
                     .limit(limit)

    # Assurez-vous d'avoir le partial _studio_card.html.erb (ou adaptez le nom)
    render partial: 'studios/studio_card', collection: @studios, as: :studio
  end

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
    @current_page = 'add_elements'
  end

  def edit
    @current_page = 'add_elements'
    # Si les studios ont des pays, décommentez :
    # @country_1, @country_2, @country_3 = @studio.country_ids[0..2]
  end

  def create
    @studio = Studio.new(studio_params)
    @studio.user = current_user
    token = params[:recaptcha_token]

    if verify_recaptcha(token) && @studio.save
      update_suivi_references_emises(current_user)
      create_notification(@studio)
      flash[:success] = I18n.t('studio.create.success', default: "Studio créé avec succès")
      redirect_to @studio
    else
      # @countries = Country.order(:country) # Si utilisé dans le formulaire
      flash.now[:alert] = I18n.t('studio.create.failure', default: "Erreur lors de la création")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Utilisation de friendly.find si vous utilisez friendly_id pour les studios aussi
    # Sinon Studio.find(params[:id])
    @studio = Studio.friendly.find(params[:slug])

    if @studio.update(studio_params)
      flash[:success] = I18n.t('studio.update.success', default: "Studio mis à jour")
      redirect_to @studio
    else
      # @countries = Country.order(:country)
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
    
    # Si vous avez une table RejectedStudio, décommentez et adaptez :
    # RejectedStudio.create!(nom: @studio.nom, user: @studio.user, reason: rejection_reason)

    # Suppression des associations si nécessaire (adaptez les noms)
    @studio.studios_domaines.delete_all if @studio.respond_to?(:studios_domaines)
    # @studio.studio_countries.delete_all if @studio.respond_to?(:studio_countries)

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
        update_suivi_references_refusees(@studio.user) # Ou une autre métrique pour "annulé"
        flash[:notice] = I18n.t('studio.cancel.success', default: "Soumission annulée")
        redirect_to add_elements_path # Ou studios_path
    else
        flash[:alert] = I18n.t('studio.cancel.denied', default: "Action non autorisée")
        redirect_to @studio
    end
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
    # Recherche insensible à la casse sur le NOM uniquement pour les studios
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
      # Logique après suppression réussie (notifs, redirection...)
      redirect_to validation_path, notice: I18n.t('studio.destroy.success', name: studio.nom, default: "Studio supprimé")
  end

  # Méthodes de suivi (identiques à DesignersController)
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

  # Notifications (adaptez les clés de traduction)
  def create_notification(studio)
    message = I18n.t('notifications.new_studio', name: studio.nom, default: "Nouveau studio : #{studio.nom}")
    User.where("role = ? OR certified = ?", 'admin', true).each do |user|
      Notification.create(user_id: user.id, notifiable: studio, message: message)
    end
  end

  def create_validation_notification(studio)
    return unless studio.user_id
    message = I18n.t('notifications.studio_validated', name: studio.nom, default: "Votre studio #{studio.nom} a été validé.")
    Notification.create(user_id: studio.user_id, notifiable: studio, message: message)
  end

  def create_rejection_notification(studio)
     return unless studio.user_id
     message = I18n.t('notifications.studio_rejected', name: studio.nom, default: "Votre studio #{studio.nom} a été refusé.")
     # Note : notifiable sera nil si le studio est détruit, vous voudrez peut-être adapter cela
     Notification.create(user_id: studio.user_id, message: message) 
  end

  def set_studio
    # Adaptez selon si vous utilisez friendly_id ou non
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
      # :recaptcha_token, # Pas besoin de le permuter s'il n'est pas en BDD
      domaine_ids: [],
      country_ids: [],
      source: []
    )
  end
end