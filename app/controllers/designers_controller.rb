class DesignersController < ApplicationController
  include RecaptchaHelper

  before_action :set_designer, only: %i[show edit update destroy cancel validate cancel reject]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :cancel, :validate]
  before_action :check_certified, only: [:validate, :destroy, :edit, :reject]
  # GET /designers or /designers.json
  def index
    @designers = Designer.where(validation: true).order("RANDOM()").limit(2)
    @current_page = 'accueil'
  end
  def load_more
    offset = params[:offset].to_i
    limit = 2
    loaded_ids = params[:loaded_ids].split(',').map(&:to_i) if params[:loaded_ids]

    @designers = Designer.where(validation: true)
                     .where.not(id: loaded_ids)
                     .order("RANDOM()")
                     .offset(offset)
                     .limit(limit)

    render partial: 'designers/card', collection: @designers, as: :card, locals: { class_name: 'card' }
  end
  
  # GET /designers/1 or /designers/1.json
  def show
    @domaines = @designer.domaines
    if user_signed_in?
      unless @designer.validation || current_user.admin? || @designer.user == current_user || current_user.certified?
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette œuvre."
      end
      @lists = current_user.lists
    else
      unless @designer.validation
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette œuvre."
      end
      @lists = []
    end
  end
  # GET /designers/new
  def new
    @designer = Designer.new
    @current_page = 'add_elements'
    
  end

  # GET /designers/1/edit
  def edit
    @current_page = 'add_elements'
    # Pré-remplir les pays en tant que variables d'instance
    @country_1 = @designer.country_ids[0]
    @country_2 = @designer.country_ids[1]
    @country_3 = @designer.country_ids[2]
  end

  # POST /designers or /designers.json
  def create
    @designer = Designer.new(designer_params)
    @designer.user = current_user

      if @designer.save
        update_suivi_references_emises(current_user)
        create_notification(@designer)
        flash[:success] = "Designer créé avec succès."
        redirect_to @designer
      else
        # Charger les pays à nouveau en cas d'échec de validation
        @countries = Country.order(:country)
        flash.now[:alert] = "Veuillez corriger les erreurs avant de soumettre à nouveau."
        render :new, status: :unprocessable_entity
      end

  end


  # PATCH/PUT /designers/1 or /designers/1.json
  def update
    @designer = Designer.friendly.find(params[:slug])

    # Collecter les IDs des pays
    country_ids = [params[:designer][:country_1], params[:designer][:country_2], params[:designer][:country_3]].reject(&:blank?)
    @designer.country_ids = country_ids

    if @designer.update(designer_params)
      flash[:success] = "Designer mis à jour avec succès."
      redirect_to @designer
    else
      @countries = Country.order(:country)
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /designers/1 or /designers/1.json
  def destroy
    @designer = Designer.find_by(slug: params[:slug])
    if @designer
      handle_destroy(@designer, "Le designer #{@designer.nom_designer} a été supprimé avec succès.")
    else
      respond_to do |format|
        format.html { redirect_to validation_path, alert: "Designer non trouvé." }
        format.json { render json: { error: "Designer non trouvé" }, status: :not_found }
      end
    end
  end
  

  # PATCH/PUT /designers/1/reject
  def reject
    rejection_reason = params[:rejection_reason].presence || "Sans commentaire"
    @designer = Designer.find_by(slug: params[:slug])
  
    if @designer
      @rejected_designer = RejectedDesigner.new(
        nom: @designer.nom,
        prenom: @designer.prenom,
        user: @designer.user,
        reason: rejection_reason
      )
      if @rejected_designer.save
        # Ajoutez rejection_reason au designer avant de le détruire
        @designer.update(rejection_reason: rejection_reason)
        
        handle_destroy(@designer, "Le designer a été refusé avec succès.")
      else
        redirect_to validation_path, alert: "Une erreur s'est produite lors du refus du designer."
      end
    else
      redirect_to validation_path, alert: "Designer non trouvé."
    end
  end  

  def cancel
    if user_signed_in?
      if current_user.admin? || @designer.user_id == current_user.id
        update_suivi_references_refusees(@designer.user)
        @designer.destroy!
        flash[:notice] = "La soumission du designer a été annulée avec succès."
        redirect_to designers_path
      else
        flash[:notice] = "Vous n'avez pas l'autorisation d'annuler cette soumission."
        redirect_to designers_path
      end
    end
  end


  def validate
    if @designer.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@designer)
      update_suivi_references_validees(@designer.user)
      redirect_to validation_path, notice: "Le/La designer #{@designer.nom_designer} a été validé(e) avec succès."
    else
      redirect_to validation_path, alert: "Une erreur s'est produite lors de la validation du designer."
    end
  end

  def load_more_designers
    offset = params[:offset].to_i
    loaded_ids = params[:loaded_ids] || []

    designers = Designer.where(validation: true).where.not(id: loaded_ids).limit(8).offset(offset)
    if designers.any?
      render partial: "designer_card", collection: designers, as: :designer
    else
      head :no_content
    end
  rescue => e
    Rails.logger.error("Erreur dans load_more_designers : #{e.message}")
    render json: { error: "Une erreur s'est produite." }, status: 500
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
    message = "Un nouveau designer est à valider : #{designer.nom_designer}"
    admins = User.where(role: 'admin')
    admins.each do |admin|
      Notification.create(user_id: admin.id, notifiable: designer, message: message)
    end
  end

  def create_validation_notification(designer)
    message = "Le designer #{designer.nom_designer} a été validé(e). Encore un grand merci pour ta contribution"

    if designer.user_id.present?
      Notification.create(user_id: designer.user_id, notifiable: designer, message: message)
    else
      Notification.create(notifiable: designer, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    # Gérez l'erreur ici, par exemple, en affichant un message ou en enregistrant les détails de l'erreur dans les journaux
    Rails.logger.error("Erreur lors de la création de la notification : #{e.message}")
  end
  def create_rejection_notification(designer)
    if designer.user_id.present?
      message = "Votre designer #{designer.nom_designer} a été rejeté(e)."
      Notification.create(user_id: designer.user_id, notifiable: designer, message: message)
    else
      Rails.logger.error "Designer #{designer.id} n'a pas d'utilisateur associé pour la notification de rejet."
    end
  end
  def set_designer
    @designer = if params[:id]
                Designer.friendly.find(params[:id])
              else
                Designer.friendly.find(params[:slug])
              end
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
      country_ids: []
    )
  end
end
