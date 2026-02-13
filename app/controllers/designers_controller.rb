class DesignersController < ApplicationController
  include RecaptchaHelper
  include ApplicationHelper

  before_action :set_designer, only: %i[show edit update destroy cancel validate reject]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :cancel, :validate]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]

  AD_FREQUENCY_RANGE = 4..7
  AD_FIRST_POSITION_RANGE = 3..5

  def index
    # --- OPTIMISATION ---
    designers = Designer.where(validation: true)
                        .includes(:domaines, designer_images: { file_attachment: :blob })
                        .order("RANDOM()")
                        .limit(9)

    studios = Studio.where(validation: true)
                    .includes(:domaines, studio_images: { file_attachment: :blob })
                    .order("RANDOM()")
                    .limit(1)

    raw_items = (designers + studios).shuffle

    @current_page = 'accueil'

    # --- NOUVELLE LOGIQUE DE PUB (Poids + Ciblage) ---
    # 1. On récupère les pubs actives et pertinentes pour l'utilisateur
    candidate_ads = Ad.currently_active.relevant_for(current_user)

    # 2. Tri pondéré (les pubs avec un gros poids sortent plus souvent au début)
    ads = candidate_ads.sort_by { |ad| -1 * (rand * ad.weight) }

    # 3. On sauvegarde l'ordre pour le "load more"
    @ads_order_string = ads.map(&:id).join(',')
    
    @items = []
    ad_index = 0
    @items_until_next_ad = rand(AD_FIRST_POSITION_RANGE)

    if user_signed_in?
      @saved_designer_ids = current_user.saved_designers.pluck(:id)
      @saved_studio_ids = current_user.saved_studios.pluck(:id)
    else
      @saved_designer_ids = []
      @saved_studio_ids = []
    end

    raw_items.each do |item|
      @items << item
      @items_until_next_ad -= 1
      if @items_until_next_ad == 0 && ads.present?
        @items << ads[ad_index % ads.length]
        ad_index += 1
        @items_until_next_ad = rand(AD_FREQUENCY_RANGE)
      end
    end
  end

  def load_more
    # Récupération des IDs déjà chargés
    loaded_designer_ids = params[:loaded_designer_ids]&.split(',')&.map(&:to_i) || []
    loaded_studio_ids = params[:loaded_studio_ids]&.split(',')&.map(&:to_i) || []
    
    if loaded_designer_ids.empty? && params[:loaded_ids].present?
       loaded_designer_ids = params[:loaded_ids]&.split(',')&.map(&:to_i) || []
    end

    # Chargement des items suivants
    new_designers = Designer.where(validation: true)
                         .where.not(id: loaded_designer_ids)
                         .includes(:domaines, designer_images: { file_attachment: :blob })
                         .order("RANDOM()")
                         .limit(3)
    
    new_studios = Studio.where(validation: true)
                         .where.not(id: loaded_studio_ids)
                         .includes(:domaines, studio_images: { file_attachment: :blob })
                         .order("RANDOM()")
                         .limit(1)

    mixed_items = (new_designers + new_studios).shuffle

    # Gestion Pubs (Paramètres)
    items_until_next_ad = params[:items_until_next_ad].present? ? params[:items_until_next_ad].to_i : rand(AD_FREQUENCY_RANGE)
    ad_index = params[:ad_index].present? ? params[:ad_index].to_i : 0

    # --- RECUPERATION DES PUBS EN DB (COHÉRENCE) ---
    if params[:ads_order].present?
      ordered_ad_ids = params[:ads_order].split(',').map(&:to_i)
      # On recharge les objets Ad depuis la BDD en respectant l'ordre exact
      ads = Ad.where(id: ordered_ad_ids)
              .index_by(&:id)
              .values_at(*ordered_ad_ids)
              .compact
    else
      ads = []
    end

    html_output = "" 

    mixed_items.each do |item|
      if item.is_a?(Designer)
        card_html = render_to_string(partial: 'designers/card', locals: { card: item, class_name: 'card' }, formats: [:html])
        html_output += "<div data-entity-type='designer' data-id='#{item.id}' class='entity-wrapper'>#{card_html}</div>"
      elsif item.is_a?(Studio)
        card_html = render_to_string(partial: 'studios/card', locals: { card: item, class_name: 'card' }, formats: [:html])
        html_output += "<div data-entity-type='studio' data-id='#{item.id}' class='entity-wrapper'>#{card_html}</div>"
      end
      
      items_until_next_ad -= 1
      if items_until_next_ad == 0 && ads.present?
        current_ad = ads[ad_index % ads.length]
        # On utilise le partial existant (qui gère désormais les objets ActiveRecord)
        html_output += render_to_string(partial: 'oeuvres/ad_card', locals: { ad: current_ad }, formats: [:html])
        ad_index += 1
        items_until_next_ad = rand(AD_FREQUENCY_RANGE)
      end
    end
    
    render json: { 
      html: html_output.html_safe, 
      items_until_next_ad: items_until_next_ad,
      ad_index: ad_index
    }
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
    if user_signed_in?
      @saved_designer_ids = current_user.saved_designers.pluck(:id)
    else
      @saved_designer_ids = []
    end
  end

  def new
    @designer = Designer.new
    @current_page = 'add_elements'
    3.times do |i|
      @designer.designer_images.build(position: i + 1)
    end
  end

  def edit
    @current_page = 'add_elements'
   existing_images = @designer.designer_images.count
  
    (3 - existing_images).times do |i|
      max_pos = @designer.designer_images.map(&:position).compact.max || 0
      @designer.designer_images.build(position: max_pos + i + 1)
    end
  end

  def create
    @designer = Designer.new(designer_params)
    @designer.user = current_user
    token = params[:recaptcha_token]

    if verify_recaptcha(token) && @designer.save
      Rails.cache.delete("linkify_keywords_list")
      update_suivi_references_emises(current_user)
      create_notification(@designer)
      flash[:success] = I18n.t('designer.create.success')
      redirect_to @designer
    else
      @countries = Country.order(:country)
      flash.now[:alert] = I18n.t('designer.create.failure')
      3.times do |i|
        @designer.designer_images.build(position: i + 1)
      end
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
      (3 - @designer.designer_images.count).times { @designer.designer_images.build }
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @designer = Designer.find_by(slug: params[:slug])
      create_rejection_notification(@designer)
      update_suivi_references_refusees(@designer.user)
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

      handle_destroy(@designer, I18n.t('designer.reject.success'))
    rescue => e
      Rails.logger.error("Erreur rejet designer : #{e.message}")
      redirect_to validation_path, alert: I18n.t('designer.reject.failure')
    end
  end

  def cancel
    if user_signed_in? && (current_user.admin? || @designer.user_id == current_user.id)
      @designer.destroy
    
      update_suivi_references_refusees(@designer.user) if @designer.user
      
      flash[:notice] = "La contribution a été annulée avec succès."
    else
      flash[:alert] = "Vous n'avez pas l'autorisation d'annuler cette contribution."
    end
    redirect_to add_elements_path
  end

  def validate
    if @designer.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@designer)
      update_suivi_references_validees(@designer.user)
      GamificationService.new(@designer.user).check_contributor # Correction: @designer ici, pas @oeuvre
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

  def save_modal
    @designer = Designer.friendly.find(params[:slug])
    @lists = current_user.lists
    render layout: false
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
    title = "Nouveau designer à valider"
    message = t('notifications.new_designer', name: designer.nom_designer)
    recipients = User.where("role = ? OR certified = ?", 'admin', true)
    recipients.each do |user|
      Notification.create(user_id: user.id, notifiable: designer, title: title, message: message)
    end
  end

  def create_validation_notification(designer)
    title = "Designer validé"
    message = t('notifications.designer_validated', name: designer.nom_designer)
    if designer.user_id.present?
      Notification.create(user_id: designer.user_id, notifiable: designer, title: title, message: message)
    else
      Notification.create(notifiable: designer, title: title, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error(t('notifications.error_creation', error: e.message))
  end

  def create_rejection_notification(designer)
    if designer.user_id.present?
      title = "Designer refusé"
      message = t('notifications.designer_rejected', name: designer.nom_designer)
      Notification.create(user_id: designer.user_id, notifiable: designer, title: title, message: message)
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
      :image,
      :recaptcha_token,
      domaine_ids: [],
      country_ids: [],
      source: [],
      designer_images_attributes: [:id, :file, :credit, :_destroy, :position]
    )
  end
end