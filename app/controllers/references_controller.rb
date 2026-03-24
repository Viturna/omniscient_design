class ReferencesController < ApplicationController
  include RecaptchaHelper
  include ApplicationHelper

  before_action :set_reference, only: %i[show edit update destroy validate cancel reject]
  before_action :authenticate_user!, except: [:index, :load_more, :show]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]

  AD_FREQUENCY_RANGE = 4..7
  AD_FIRST_POSITION_RANGE = 3..5

  def index
    references = Reference.where(validation: true).limit(10).order("RANDOM()")
    @current_page = 'accueil'
    @lists = user_signed_in? ? current_user.lists : []

    candidate_ads = Ad.currently_active.relevant_for(current_user)

    ads = candidate_ads.sort_by { |ad| -1 * (rand * ad.weight) }

    @ads_order_string = ads.map(&:id).join(',')
    
    @items = []
    ad_index = 0
    @items_until_next_ad = rand(AD_FIRST_POSITION_RANGE)

    references.each do |reference|
      @items << reference
      @items_until_next_ad -= 1
      
      # Si c'est le moment d'afficher une pub et qu'il en reste
      if @items_until_next_ad == 0 && ads.present?
        @items << ads[ad_index % ads.length]
        ad_index += 1
        @items_until_next_ad = rand(AD_FREQUENCY_RANGE)
      end
    end

    if user_signed_in?
      @saved_reference_ids = current_user.saved_references.pluck(:id)
    else
      @saved_reference_ids = []
    end
  end

  def load_more
    offset = params[:offset].to_i
    limit = 2 # Tu charges peu d'references à la fois, tu pourrais augmenter à 4 ou 6
    loaded_ids = params[:loaded_ids].split(',').map(&:to_i) if params[:loaded_ids]

    @references = Reference.where(validation: true)
                     .where.not(id: loaded_ids)
                     .order("RANDOM()")
                     .limit(limit)

    items_until_next_ad = params[:items_until_next_ad].present? ? params[:items_until_next_ad].to_i : rand(AD_FREQUENCY_RANGE)
    ad_index = params[:ad_index].present? ? params[:ad_index].to_i : 0

    if params[:ads_order].present?
      ordered_ad_ids = params[:ads_order].split(',').map(&:to_i)
      
      ads = Ad.where(id: ordered_ad_ids)
              .index_by(&:id)
              .values_at(*ordered_ad_ids)
              .compact
    else
      ads = [] 
    end

    html_output = "" 
    @references.each do |reference|
      html_output += render_to_string(partial: 'references/card', locals: { card: reference, class_name: 'card' }, formats: [:html])
      
      items_until_next_ad -= 1
      if items_until_next_ad == 0 && ads.present?
        current_ad = ads[ad_index % ads.length]
        
        # On passe 'current_ad' (objet ActiveRecord) à la partial
        html_output += render_to_string(partial: 'references/ad_card', locals: { ad: current_ad }, formats: [:html])
        
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

  # ... Le reste du contrôleur (show, new, edit...) reste inchangé ...
  # ... (Copie-colle tes méthodes show, new, create, etc. ici) ...

  # GET /references/1 or /references/1.json
  def show
    @domaines = @reference.domaines
    unless @reference.validation || (user_signed_in? && (current_user.admin? || @reference.user == current_user || current_user.certified?))
      redirect_to root_path, alert: t('references.access_denied')
      return
    end
    @lists = user_signed_in? ? current_user.lists : []
    if user_signed_in?
      @saved_reference_ids = current_user.saved_references.pluck(:id)
    else
      @saved_reference_ids = []
    end

    @domaine_references = Reference
                       .joins(:domaines)
                       .where(domaines: { id: @domaines.ids })
                       .where(validation: true)
                       .where.not(id: @reference.id)
                       .order("RANDOM()")
                       .limit(5)
  end

  # GET /references/new
  def new
    @reference = Reference.new
    3.times do |i|
      @reference.reference_images.build(position: i + 1)
    end

    @current_page = 'add_elements'
    @selected_designers = [] 
  end

  # GET /references/1/edit
  def edit
    @current_page = 'add_elements'
    @selected_designers = @reference.designers.pluck(:id)

    existing_images = @reference.reference_images.count
  
    (3 - existing_images).times do |i|
      max_pos = @reference.reference_images.map(&:position).compact.max || 0
      @reference.reference_images.build(position: max_pos + i + 1)
    end
  end

  # POST /references or /references.json
  def create
    @reference = Reference.new(reference_params)
    @reference.user = current_user

    if @reference.save
      Rails.cache.delete("linkify_keywords_list")
      update_suivi_references_emises(current_user)
      create_notification(@reference)
      flash[:success] = t('references.create.success')
      redirect_to @reference
    else
      3.times do |i|
        @reference.reference_images.build(position: i + 1)
      end
      render :new, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /references/1 or /references/1.json
   def update
    if @reference.update(reference_params)
      redirect_to @reference, notice: t('references.update.success')
    else
      flash.now[:alert] = t('references.update.failure')
      render :edit, status: :unprocessable_entity
    end
  end



# PATCH/PUT /references/:slug/reject
  def reject
    rejection_reason = params[:rejection_reason].presence || I18n.t('reference.reject.no_comment')
    @reference = Reference.friendly.find_by(slug: params[:slug])

    unless @reference
      redirect_to validation_path, alert: I18n.t('references.not_found') and return
    end

    ActiveRecord::Base.transaction do
      # 1. Création de l'historique de rejet
      RejectedReference.create!(
        nom_reference: @reference.nom_reference,
        user: @reference.user,
        reason: rejection_reason
      )
      
      # 2. Nettoyage des jointures avec la même logique sécurisée que pour les designers
      @reference.references_domaines.delete_all if @reference.respond_to?(:references_domaines)
      @reference.designers_references.delete_all if @reference.respond_to?(:designers_references)
      @reference.reference_studios.delete_all if @reference.respond_to?(:reference_studios)
      @reference.references_verbs.delete_all if @reference.respond_to?(:references_verbs)
      @reference.list_items.delete_all if @reference.respond_to?(:list_items)

      # 3. Mise à jour du statut avant destruction
      @reference.update!(rejection_reason: rejection_reason, validation: false)

      # 4. Délégation à handle_destroy
      handle_destroy(@reference, I18n.t('references.reject.success', default: 'Référence refusée avec succès.'))
    rescue => e
      Rails.logger.error("Erreur rejet référence : #{e.message}")
      redirect_to validation_path, alert: I18n.t('references.reject.failure', default: 'Erreur lors du refus de la référence.')
    end
  end

  # DELETE /references/1 or /references/1.json
   def destroy
    if @reference&.destroy
      create_rejection_notification(@reference)
      update_suivi_references_refusees(@reference.user)
      redirect_to validation_path, notice: t('references.destroy.success', name: @reference.nom_reference)
    else
      redirect_to validation_path, alert: t('references.destroy.failure')
    end
  end
  
  def cancel
    if user_signed_in? && (current_user.admin? || @reference.user_id == current_user.id)
      @reference.destroy
    
      update_suivi_references_refusees(@reference.user) if @reference.user
      
      flash[:notice] = "La contribution a été annulée avec succès."
    else
      flash[:alert] = "Vous n'avez pas l'autorisation d'annuler cette contribution."
    end
    redirect_to add_elements_path
  end

 def validate
    if @reference.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@reference)
      update_suivi_references_validees(@reference.user)
      GamificationService.new(@reference.user).check_contributor
      redirect_to validation_path, notice: t('references.validate.success', name: @reference.nom_reference)
    else
      redirect_to validation_path, alert: t('references.validate.failure', errors: @reference.errors.full_messages.join(', '))
    end
  end

  def check_existence
    reference = Reference.find_by("LOWER(nom_reference) = ?", params[:nom_reference].downcase)
  
    if reference
      if reference.validated?
        render json: { exists: true, edit_path: nil }
      else
        render json: { exists: true, edit_path: edit_reference_path(reference) }
      end
    else
      render json: { exists: false }
    end
  end
  
def save_modal
    @reference = Reference.friendly.find(params[:slug])
    @lists = current_user.lists
    render layout: false
  end
  
  private
  def update_image_credits(reference, params)
    if params[:reference][:existing_image_credits]
      params[:reference][:existing_image_credits].each do |blob_id, credit_text|
        blob = ActiveStorage::Blob.find_by(id: blob_id)
        blob&.update(metadata: { credit: credit_text.presence })
      end
    end

    if params[:reference][:new_image_credits]
      new_attachments = reference.images_attachments
                              .where.not(id: reference.images.map(&:id)) # Exclut les anciens
                              .order(:id) # On suppose que l'ordre de création = ordre du form
                              
      new_credits = params[:reference][:new_image_credits]

      new_attachments.each_with_index do |attachment, index|
        credit_text = new_credits[index]
        if credit_text.present?
          attachment.blob.update(metadata: { credit: credit_text })
        end
      end
    end
  rescue => e
    Rails.logger.error "ERREUR update_image_credits: #{e.message}"
  end

  def handle_destroy(reference, success_message)
    if reference.destroy
      create_rejection_notification(reference)
      update_suivi_references_refusees(reference.user)
  
      respond_to do |format|
        format.html { redirect_to validation_path, notice: success_message }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to validation_path, alert: "Une erreur est survenue lors de la suppression de la référence." }
        format.json { render json: reference.errors, status: :unprocessable_entity }
      end
    end
  end
  def create_notification(reference)
    title = "Nouvelle référence à valider"
    message = t('notifications.new_reference', name: reference.nom_reference)
    
    recipients = User.where("role = ? OR certified = ?", 'admin', true)

    recipients.each do |user|
      Notification.create(
        user_id: user.id, 
        notifiable: reference, 
        title: title,
        message: message
      )
    end
  end

  def create_validation_notification(reference)
    title = "Référence validée"
    message = t('notifications.reference_validated', name: reference.nom_reference)

    if reference.user_id.present?
      Notification.create(
        user_id: reference.user_id, 
        notifiable: reference, 
        title: title,
        message: message
      )
    else
      Notification.create(
        notifiable: reference, 
        title: title,
        message: message
      )
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error(t('notifications.error_creation', error: e.message))
  end

  def create_rejection_notification(reference)
    if reference.user_id.present?
      title = "Référence refusée"
      message = t('notifications.reference_rejected', name: reference.nom_reference)
      
      Notification.create(
        user_id: reference.user_id, 
        notifiable: reference, 
        title: title,
        message: message
      )
    else
      Rails.logger.error(t('notifications.no_user_for_rejection', reference_id: reference.id))
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
    return unless user
    suivi = user.suivis.first_or_create
    suivi.increment(:nb_references_refusees)
    suivi.save
  end

  def set_reference
    @reference = if params[:id]
                Reference.friendly.find(params[:id])
              else
                Reference.friendly.find(params[:slug])
              end
  rescue ActiveRecord::RecordNotFound
    redirect_to validation_path, alert: t('references.not_found') and return
  end

 def reference_params
    permitted = params.require(:reference).permit(
      :nom_reference,
      :presentation_generale,
      :contexte_historique,
      :materiaux_et_innovations_techniques,
      :concept_et_inspiration,
      :dimension_esthetique,
      :impact_et_message,
      :date_reference,
      designer_ids: [],
      verb_ids: [],
      domaine_ids: [],
      studio_ids: [],
      source: [],
      reference_images_attributes: [
          :id,    
          :file, 
          :credit,
          :_destroy,
          :position
        ]
    )

    [:designer_ids, :notion_ids, :domaine_ids, :studio_ids, :source].each do |key|
      if permitted[key].is_a?(Array)
        permitted[key] = permitted[key].reject(&:blank?) 
      end
    end

    permitted
  end

end