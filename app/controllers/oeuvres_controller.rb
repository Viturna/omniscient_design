class OeuvresController < ApplicationController
  include RecaptchaHelper

  before_action :set_oeuvre, only: %i[show edit update destroy validate cancel reject]
  before_action :authenticate_user!, except: [:index, :show, :load_more]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]
  # GET /oeuvres or /oeuvres.json
  def index
    @oeuvres = Oeuvre.where(validation: true).limit(2).order("RANDOM()")
    @current_page = 'accueil'
    if user_signed_in?
      @lists = current_user.lists
    else
      @lists = []
    end
  end

  def load_more
    offset = params[:offset].to_i
    limit = 2
    loaded_ids = params[:loaded_ids].split(',').map(&:to_i) if params[:loaded_ids]

    @oeuvres = Oeuvre.where(validation: true)
                     .where.not(id: loaded_ids)
                     .order("RANDOM()")
                     .offset(offset)
                     .limit(limit)

    render partial: 'oeuvres/card', collection: @oeuvres, as: :card, locals: { class_name: 'card' }
  end 

  # GET /oeuvres/1 or /oeuvres/1.json
  def show
    if user_signed_in?
      unless @oeuvre.validation || current_user.admin? || @oeuvre.user == current_user || current_user.certified?
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette référence."
      end
      @lists = current_user.lists
    else
      unless @oeuvre.validation
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette référence."
      end
      @lists = []
    end
  end

  # GET /oeuvres/new
  def new
    @oeuvre = Oeuvre.new
    @current_page = 'add_elements'
    @selected_designers = [] 
  end

  # GET /oeuvres/1/edit
  def edit
    @current_page = 'add_elements'
    @selected_designers = @oeuvre.designers.pluck(:id)
  end

  # POST /oeuvres or /oeuvres.json
  def create
    @oeuvre = Oeuvre.new(oeuvre_params)
    @oeuvre.user = current_user

    if @oeuvre.save
      if params[:oeuvre][:image].present?
        @oeuvre.image.attach(params[:oeuvre][:image])
      end
      update_suivi_references_emises(current_user)
      create_notification(@oeuvre)
      flash[:success] = "Référence créée avec succès."
      redirect_to @oeuvre
    else
      render :new, status: :unprocessable_entity
    end
  end

  

  # PATCH/PUT /oeuvres/1 or /oeuvres/1.json
  def update
    respond_to do |format|
      if @oeuvre.update(oeuvre_params)
        format.html { redirect_to oeuvre_url(@oeuvre), notice: "Référence mise à jour" }
        format.json { render :show, status: :ok, location: @oeuvre }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @oeuvre.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oeuvres/1/reject
  def reject
    rejection_reason = params[:rejection_reason].presence || "Sans commentaire"
    @oeuvre = Oeuvre.find_by(slug: params[:slug])

    if @oeuvre
      @rejected_oeuvre = RejectedOeuvre.new(
        nom_oeuvre: @oeuvre.nom_oeuvre,
        user: @oeuvre.user,
        reason: rejection_reason
      )

      if @rejected_oeuvre.save
        if @oeuvre.notions_oeuvres.exists?
          Rails.logger.info "Suppression des notions associées à l'oeuvre #{@oeuvre.id}"
          @oeuvre.notions_oeuvres.delete_all
        end

        # Détruire l'oeuvre
        handle_destroy(@oeuvre, "La référence a été refusée avec succès.")
      else
        redirect_to validation_path, alert: "Une erreur est survenue lors du refus de la référence."
      end
    else
      redirect_to validation_path, alert: "Oeuvre non trouvée."
    end

    Rails.logger.info "CSRF token reçu : #{request.headers['X-CSRF-Token']}"
  end

  # DELETE /oeuvres/1 or /oeuvres/1.json
  def destroy
    @oeuvre = Oeuvre.find_by(slug: params[:slug])
    if @oeuvre
      handle_destroy(@oeuvre, "La référence #{@oeuvre.nom_oeuvre} a été supprimée avec succès.")
    else
      respond_to do |format|
        format.html { redirect_to validation_path, alert: "Une erreur est survenue lors de la suppression de la référence." }
        format.json { render json: { error: "Oeuvre non trouvée" }, status: :not_found }
      end
    end
  end

  def cancel
    if user_signed_in?
      if current_user.admin? || @oeuvre.user_id == current_user.id
        update_suivi_references_refusees(@oeuvre.user)
        @oeuvre.destroy!
        flash[:notice] = "La soumission de la référence a été annulée avec succès."
        redirect_to oeuvres_path
      else
        flash[:notice] = "Vous n'avez pas l'autorisation d'annuler cette soumission."
        redirect_to oeuvres_path
      end
    end
  end

  def validate
    if @oeuvre.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@oeuvre)
      update_suivi_references_validees(@oeuvre.user)
      redirect_to validation_path, notice: "La référence #{@oeuvre.nom_oeuvre} a été validée avec succès."
    else
      Rails.logger.error "Erreur lors de la validation de la référence : #{@oeuvre.errors.full_messages}"
      redirect_to validation_path, alert: "Échec de validation : #{@oeuvre.errors.full_messages.join(', ')}"
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
    message = "Une nouvelle oeuvre est à valider : #{oeuvre.nom_oeuvre}"
    admins = User.where(role: 'admin')
    admins.each do |admin|
      Notification.create(user_id: admin.id, notifiable: oeuvre, message: message)
    end
  end

  def create_validation_notification(oeuvre)
    message = "La référence #{oeuvre.nom_oeuvre} a été validée. Encore un grand merci pour ta contribution"

    if oeuvre.user_id.present?
      Notification.create(user_id: oeuvre.user_id, notifiable: oeuvre, message: message)
    else
      Notification.create(notifiable: oeuvre, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error("Erreur lors de la création de la notification : #{e.message}")
  end

  def create_rejection_notification(oeuvre)
    if oeuvre.user_id.present?
      message = "Votre référence #{oeuvre.nom_oeuvre} a été rejeté(e)."
      Notification.create(user_id: oeuvre.user_id, notifiable: oeuvre, message: message)
    else
      Rails.logger.error "La référence #{oeuvre.id} n'a pas d'utilisateur associé pour la notification de rejet."
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
    redirect_to validation_path, alert: "La référence n'a pas été trouvée."
  end

  def oeuvre_params
    params.require(:oeuvre).permit(
      :nom_oeuvre, :date_oeuvre, :presentation_generale, :contexte_historique,
      :materiaux_et_innovations_techniques, :concept_et_inspiration,
      :dimension_esthetique, :impact_et_message, :image, :domaine_id, :recaptcha_token, designer_ids: [], concept_ids: [], notion_ids: []
    )
  end
end
