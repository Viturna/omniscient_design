class ReferencesController < ApplicationController
  include ContributionManageable
  include RecaptchaHelper
  include ApplicationHelper

  before_action :set_reference, only: %i[show edit update destroy validate cancel reject]
  before_action :authenticate_user!, except: %i[index load_more show]
  before_action :check_certified, only: %i[validate destroy reject]
  before_action :check_edit_permission, only: %i[edit update]

  AD_FREQUENCY_RANGE = 4..6
  AD_FIRST_POSITION_RANGE = 3..5

  def index
    references = Reference.where(validation: true).preload(:domaines, :designers, :studios,
                                                           reference_images: :file_attachment).limit(10).order('RANDOM()')
    @current_page = 'accueil'
    @lists = user_signed_in? ? current_user.lists : []

    candidate_ads = Ad.currently_active.includes(image_attachment: :blob,
                                                 image_mobile_attachment: :blob).relevant_for(current_user)

    ads = candidate_ads.sort_by { |ad| -1 * (rand * ad.weight) }

    @ads_order_string = ads.map(&:id).join(',')

    @items = []
    ad_index = 0
    @items_until_next_ad = rand(AD_FIRST_POSITION_RANGE)

    references.each do |reference|
      @items << reference
      @items_until_next_ad -= 1

      # Si c'est le moment d'afficher une pub et qu'il en reste
      next unless @items_until_next_ad == 0 && ads.present?

      @items << ads[ad_index % ads.length]
      ad_index += 1
      @items_until_next_ad = rand(AD_FREQUENCY_RANGE)
    end

    @saved_reference_ids = if user_signed_in?
                             current_user.saved_references.pluck(:id)
                           else
                             []
                           end
  end

  def load_more
    limit = 2
    loaded_ids = params[:loaded_ids].split(',').map(&:to_i) if params[:loaded_ids]

    @references = Reference.where(validation: true)
                           .preload(:domaines, :designers, :studios, reference_images: :file_attachment)
                           .where.not(id: loaded_ids)
                           .order('RANDOM()')
                           .limit(limit)

    items_until_next_ad = params[:items_until_next_ad].present? ? params[:items_until_next_ad].to_i : rand(AD_FREQUENCY_RANGE)
    ad_index = params[:ad_index].present? ? params[:ad_index].to_i : 0

    if params[:ads_order].present?
      ordered_ad_ids = params[:ads_order].split(',').map(&:to_i)

      ads = Ad.includes(image_attachment: :blob, image_mobile_attachment: :blob)
              .where(id: ordered_ad_ids)
              .index_by(&:id)
              .values_at(*ordered_ad_ids)
              .compact
    else
      ads = []
    end

    html_output = ''
    @references.each do |reference|
      html_output += render_to_string(partial: 'references/card', locals: { card: reference, class_name: 'card' },
                                      formats: [:html])

      items_until_next_ad -= 1
      next unless items_until_next_ad == 0 && ads.present?

      current_ad = ads[ad_index % ads.length]

      # On passe 'current_ad' (objet ActiveRecord) à la partial
      html_output += render_to_string(partial: 'references/ad_card', locals: { ad: current_ad }, formats: [:html])

      ad_index += 1
      items_until_next_ad = rand(AD_FREQUENCY_RANGE)
    end

    render json: {
      html: html_output.html_safe,
      items_until_next_ad: items_until_next_ad,
      ad_index: ad_index
    }
  end

  def show
    @domaines = @reference.domaines
    unless @reference.validation || (user_signed_in? && (current_user.admin? || @reference.user == current_user || current_user.certified?))
      redirect_to root_path, alert: t('references.access_denied')
      return
    end

    image_url = @reference.reference_images.first&.file&.attached? ? view_context.url_for(@reference.reference_images.first.file) : nil
    designers_names = @reference.designers.map { |d| "#{d.prenom} #{d.nom}".strip }.join(', ')
    optimized_title = designers_names.present? ? "#{@reference.nom_reference} par #{designers_names} - Référence Design" : "#{@reference.nom_reference} - Référence Design"

    set_meta_tags(
      title: optimized_title,
      description: view_context.truncate(@reference.presentation_generale, length: 160),
      og: { image: image_url },
      twitter: { image: image_url }
    )

    @lists = user_signed_in? ? current_user.lists : []
    @saved_reference_ids = if user_signed_in?
                             current_user.saved_references.pluck(:id)
                           else
                             []
                           end

    @domaine_references = Reference
                          .joins(:domaines)
                          .where(domaines: { id: @domaines.ids })
                          .where(validation: true)
                          .where.not(id: @reference.id)
                          .preload(:domaines, :designers, :studios, reference_images: :file_attachment)
                          .order('RANDOM()')
                          .limit(5)
  end

  def new
    @reference = Reference.new
    3.times do |i|
      @reference.reference_images.build(position: i + 1)
    end

    @current_page = 'add_elements'
    @selected_designers = []
  end

  def edit
    @current_page = 'add_elements'
    @selected_designers = @reference.designers.pluck(:id)

    existing_images = @reference.reference_images.count

    (3 - existing_images).times do |i|
      max_pos = @reference.reference_images.map(&:position).compact.max || 0
      @reference.reference_images.build(position: max_pos + i + 1)
    end
  end

  def create
    @reference = Reference.new(reference_params)
    @reference.user = current_user

    if @reference.save
      Rails.cache.delete('linkify_keywords_list')
      update_suivi_references_emises(current_user)
      create_notification(@reference)
      create_author_notification(@reference)
      flash[:success] = 'Nous avons bien reçu ta contribution ! Elle sera traitée dans les plus brefs délais.'
      redirect_to @reference
    else
      3.times do |i|
        @reference.reference_images.build(position: i + 1)
      end
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @reference.update(reference_params)
      notify_admin_of_update(@reference) if !@reference.validation && @reference.user == current_user
      redirect_to @reference, notice: t('references.update.success')
    else
      flash.now[:alert] = t('references.update.failure')
      render :edit, status: :unprocessable_entity
    end
  end

  def reject
    rejection_reason = params[:rejection_reason].presence || I18n.t('references.reject.no_comment',
                                                                    default: 'Sans commentaire')
    @reference = Reference.friendly.find_by(slug: params[:slug])

    redirect_to validation_path, alert: I18n.t('references.not_found') and return unless @reference

    ActiveRecord::Base.transaction do
      # 1. Création de l'historique de rejet
      RejectedReference.create!(
        nom_reference: @reference.nom_reference,
        user: @reference.user,
        reason: rejection_reason
      )

      # 2. Mise à jour du statut avant destruction (optionnel mais conservé pour cohérence si besoin)
      @reference.update!(rejection_reason: rejection_reason, validation: false)

      # 3. Délégation à handle_destroy qui gère la suppression propre via dependent: :destroy
      handle_destroy(@reference, I18n.t('references.reject.success', default: 'Référence refusée avec succès.'))
    rescue StandardError => e
      Rails.logger.error("Erreur rejet référence : #{e.message}")
      redirect_to validation_path,
                  alert: I18n.t('references.reject.failure', default: 'Erreur lors du refus de la référence.')
    end
  end

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

      flash[:notice] = 'Ta contribution a été annulée avec succès.'
    else
      flash[:alert] = "Tu n'as pas l'autorisation d'annuler cette contribution."
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
      redirect_to validation_path,
                  alert: t('references.validate.failure', errors: @reference.errors.full_messages.join(', '))
    end
  end

  def check_existence
    reference = Reference.find_by('LOWER(nom_reference) = ?', params[:nom_reference].downcase)

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

  def check_edit_permission
    unless current_user.admin? || current_user.certified? || (@reference.user == current_user && !@reference.validated?)
      redirect_to root_path, alert: t('references.access_denied', default: 'Accès refusé')
    end
  end










  def set_reference
    base_query = Reference.includes(:designers, :studios)
    @reference = base_query.friendly.find(params[:id] || params[:slug])
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
      notion_ids: [],
      domaine_ids: [],
      studio_ids: [],
      source: [],
      reference_images_attributes: %i[
        id
        file
        credit
        _destroy
        position
      ]
    )

    %i[designer_ids notion_ids domaine_ids studio_ids source].each do |key|
      permitted[key] = permitted[key].reject(&:blank?) if permitted[key].is_a?(Array)
    end

    permitted
  end
end
