class OeuvresController < ApplicationController
  include RecaptchaHelper
  include ApplicationHelper

  before_action :set_oeuvre, only: %i[show edit update destroy validate cancel reject]
  before_action :authenticate_user!, except: [:index, :load_more, :show]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]


  AD_FREQUENCY_RANGE = 4..7
  AD_FIRST_POSITION_RANGE = 3..5
  # GET /oeuvres or /oeuvres.json
  def index
    oeuvres = Oeuvre.where(validation: true).limit(10).order("RANDOM()")
    @current_page = 'accueil'
    @lists = user_signed_in? ? current_user.lists : []

    ads = ads_data.shuffle
    @ads_order_string = ads.map { |ad| ad[:id] }.join(',')
    
    @items = []
    ad_index = 0
    @items_until_next_ad = rand(AD_FIRST_POSITION_RANGE)

    oeuvres.each do |oeuvre|
      @items << oeuvre
      @items_until_next_ad -= 1
      if @items_until_next_ad == 0 && ads.present?
        @items << ads[ad_index % ads.length]
        ad_index += 1
        @items_until_next_ad = rand(AD_FREQUENCY_RANGE)
      end
    end
  end

def load_more
    offset = params[:offset].to_i
    limit = 2
    loaded_ids = params[:loaded_ids].split(',').map(&:to_i) if params[:loaded_ids]

    @oeuvres = Oeuvre.where(validation: true)
                     .where.not(id: loaded_ids)
                     .order("RANDOM()")
                     .limit(limit)

    items_until_next_ad = params[:items_until_next_ad].present? ? params[:items_until_next_ad].to_i : rand(AD_FREQUENCY_RANGE)
    ad_index = params[:ad_index].present? ? params[:ad_index].to_i : 0

    # --- LOGIQUE DE PUB MISE À JOUR (NE PLUS MÉLANGER) ---
    if params[:ads_order].present?
      ordered_ad_ids = params[:ads_order].split(',')
      # On récupère les pubs de la DB et on les trie selon l'ordre reçu
      ads_hashes = ads_data 
      ads = ads_hashes.sort_by { |ad| ordered_ad_ids.index(ad[:id].to_s) }
    else
      ads = [] # Sécurité : pas de pubs si l'ordre n'est pas passé
    end

   html_output = "" 
    @oeuvres.each do |oeuvre|
      html_output += render_to_string(partial: 'oeuvres/card', locals: { card: oeuvre, class_name: 'card' }, formats: [:html])
      
      items_until_next_ad -= 1
      if items_until_next_ad == 0 && ads.present?
        current_ad = ads[ad_index % ads.length]
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

  # GET /oeuvres/1 or /oeuvres/1.json
  def show
    @domaines = @oeuvre.domaines
    unless @oeuvre.validation || (user_signed_in? && (current_user.admin? || @oeuvre.user == current_user || current_user.certified?))
      redirect_to root_path, alert: t('oeuvres.access_denied')
      return
    end
    @lists = user_signed_in? ? current_user.lists : []

     @domaine_oeuvres = Oeuvre
                       .joins(:domaines)
                       .where(domaines: { id: @domaines.ids })
                       .where(validation: true)
                       .where.not(id: @oeuvre.id)
                       .order("RANDOM()")
                       .limit(5)
  end

  # GET /oeuvres/new
  def new
    @oeuvre = Oeuvre.new
    3.times do |i|
      @oeuvre.oeuvre_images.build(position: i + 1)
    end

    @current_page = 'add_elements'
    @selected_designers = [] 
  end

  # GET /oeuvres/1/edit
  def edit
    @current_page = 'add_elements'
    @selected_designers = @oeuvre.designers.pluck(:id)

    existing_images = @oeuvre.oeuvre_images.count
  
    (3 - existing_images).times do |i|
      max_pos = @oeuvre.oeuvre_images.map(&:position).compact.max || 0
      @oeuvre.oeuvre_images.build(position: max_pos + i + 1)
    end
  end

  # POST /oeuvres or /oeuvres.json
  def create
    @oeuvre = Oeuvre.new(oeuvre_params)
    @oeuvre.user = current_user

    if @oeuvre.save
      update_suivi_references_emises(current_user)
      create_notification(@oeuvre)
      flash[:success] = t('oeuvres.create.success')
      redirect_to @oeuvre
    else
      3.times do |i|
        @oeuvre.oeuvre_images.build(position: i + 1)
      end
      render :new, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /oeuvres/1 or /oeuvres/1.json
   def update
    if @oeuvre.update(oeuvre_params)
      redirect_to @oeuvre, notice: t('oeuvres.update.success')
    else
      flash.now[:alert] = t('oeuvres.update.failure')
      render :edit, status: :unprocessable_entity
    end
  end


 # PATCH/PUT /oeuvres/:slug/reject
def reject
  rejection_reason = params[:rejection_reason].presence || I18n.t('oeuvre.reject.no_comment')
  @oeuvre = Oeuvre.friendly.find_by(slug: params[:slug])

  unless @oeuvre
    redirect_to validation_path, alert: I18n.t('oeuvres.not_found') and return
  end

  ActiveRecord::Base.transaction do
    # Création du rejet
    @rejected_oeuvre = RejectedOeuvre.create!(
      nom_oeuvre: @oeuvre.nom_oeuvre,
      user: @oeuvre.user,
      reason: rejection_reason
    )

    # Nettoyage des associations
    @oeuvre.notions_oeuvres.delete_all if @oeuvre.notions_oeuvres.exists?
    @oeuvre.oeuvres_domaines.delete_all if @oeuvre.oeuvres_domaines.exists?
    @oeuvre.designers_oeuvres.delete_all if @oeuvre.designers_oeuvres.exists?

    # Mise à jour de la raison du rejet
    @oeuvre.update!(rejection_reason: rejection_reason, validation: false)

    handle_destroy(@oeuvre, I18n.t('oeuvres.reject.success'))
  rescue => e
    Rails.logger.error("Erreur rejet œuvre : #{e.message}")
    redirect_to validation_path, alert: I18n.t('oeuvres.reject.failure')
  end
end


  # DELETE /oeuvres/1 or /oeuvres/1.json
   def destroy
    if @oeuvre&.destroy
      create_rejection_notification(@oeuvre)
      update_suivi_references_refusees(@oeuvre.user)
      redirect_to validation_path, notice: t('oeuvres.destroy.success', name: @oeuvre.nom_oeuvre)
    else
      redirect_to validation_path, alert: t('oeuvres.destroy.failure')
    end
  end
  
  def cancel
    if user_signed_in? && (current_user.admin? || @oeuvre.user_id == current_user.id)
      update_suivi_references_refusees(@oeuvre.user)
      @oeuvre.destroy!
      flash[:notice] = t('oeuvres.cancel.success')
      redirect_to oeuvres_path
    else
      flash[:alert] = t('oeuvres.cancel.failure')
      redirect_to oeuvres_path
    end
  end

 def validate
    if @oeuvre.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@oeuvre)
      update_suivi_references_validees(@oeuvre.user)
      redirect_to validation_path, notice: t('oeuvres.validate.success', name: @oeuvre.nom_oeuvre)
    else
      redirect_to validation_path, alert: t('oeuvres.validate.failure', errors: @oeuvre.errors.full_messages.join(', '))
    end
  end

  def check_existence
    oeuvre = Oeuvre.find_by("LOWER(nom_oeuvre) = ?", params[:nom_oeuvre].downcase)
  
    if oeuvre
      if oeuvre.validated?
        render json: { exists: true, edit_path: nil }
      else
        render json: { exists: true, edit_path: edit_oeuvre_path(oeuvre) }
      end
    else
      render json: { exists: false }
    end
  end
  
  
  private
  def update_image_credits(oeuvre, params)
    # 1. Mettre à jour les crédits des images EXISTANTES
    if params[:oeuvre][:existing_image_credits]
      params[:oeuvre][:existing_image_credits].each do |blob_id, credit_text|
        # On trouve le blob (le fichier) et on met à jour ses metadata
        blob = ActiveStorage::Blob.find_by(id: blob_id)
        blob&.update(metadata: { credit: credit_text.presence })
      end
    end

    # 2. Mettre à jour les crédits des NOUVELLES images
    if params[:oeuvre][:new_image_credits]
      # On récupère les NOUVEAUX attachements (créés lors du @oeuvre.save)
      # On les trie par ID pour espérer matcher l'ordre du formulaire
      new_attachments = oeuvre.images_attachments
                              .where.not(id: oeuvre.images.map(&:id)) # Exclut les anciens
                              .order(:id) # On suppose que l'ordre de création = ordre du form
                              
      new_credits = params[:oeuvre][:new_image_credits]

      # On associe chaque crédit à chaque nouvel attachement
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

  def handle_destroy(oeuvre, success_message)
    if oeuvre.destroy
      create_rejection_notification(oeuvre)
      update_suivi_references_refusees(oeuvre.user)
  
      respond_to do |format|
        format.html { redirect_to validation_path, notice: success_message }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to validation_path, alert: "Une erreur est survenue lors de la suppression de la référence." }
        format.json { render json: oeuvre.errors, status: :unprocessable_entity }
      end
    end
  end
  def create_notification(oeuvre)
    message = t('notifications.new_oeuvre', name: oeuvre.nom_oeuvre)
    
    recipients = User.where("role = ? OR certified = ?", 'admin', true)

    recipients.each do |user|
      Notification.create(user_id: user.id, notifiable: oeuvre, message: message)
    end
  end
  def create_validation_notification(oeuvre)
    message = t('notifications.oeuvre_validated', name: oeuvre.nom_oeuvre)

    if oeuvre.user_id.present?
      Notification.create(user_id: oeuvre.user_id, notifiable: oeuvre, message: message)
    else
      Notification.create(notifiable: oeuvre, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error(t('notifications.error_creation', error: e.message))
  end

  def create_rejection_notification(oeuvre)
    if oeuvre.user_id.present?
      message = t('notifications.oeuvre_rejected', name: oeuvre.nom_oeuvre)
      Notification.create(user_id: oeuvre.user_id, notifiable: oeuvre, message: message)
    else
      Rails.logger.error(t('notifications.no_user_for_rejection', oeuvre_id: oeuvre.id))
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

  def set_oeuvre
    @oeuvre = if params[:id]
                Oeuvre.friendly.find(params[:id])
              else
                Oeuvre.friendly.find(params[:slug])
              end
  rescue ActiveRecord::RecordNotFound
   redirect_to validation_path, alert: t('oeuvres.not_found')
  end

 def oeuvre_params
  permitted = params.require(:oeuvre).permit(
    :nom_oeuvre,
    :presentation_generale,
    :contexte_historique,
    :materiaux_et_innovations_techniques,
    :concept_et_inspiration,
    :dimension_esthetique,
    :impact_et_message,
    :date_oeuvre,
    designer_ids: [],
    notion_ids: [],
    domaine_ids: [],
    source: [],
    oeuvre_images_attributes: [
        :id,    
        :file, 
        :credit,
        :_destroy,
        :position
      ]
  )

  [:designer_ids, :notion_ids, :domaine_ids, :source].each do |key|
    permitted[key] = permitted[key].reject(&:blank?) if permitted[key]
  end

  permitted
end


end
