class DesignersController < ApplicationController
  include RecaptchaHelper
  before_action :set_designer, only: %i[ show edit update destroy validate cancel]
  before_action :authenticate_user!, only: [:new]

  # GET /designers or /designers.json
  def index
    @designers = Designer.where(validation: true).limit(10).order("RANDOM()")
    @current_page = 'accueil'
  end
  def load_more
    offset = params[:offset].to_i
    @designers = Designer.where(validation: true).offset(offset).limit(10).order("RANDOM()")
    render partial: 'designers/card', collection: @designers, as: :card
  end

  # GET /designers/1 or /designers/1.json
  def show
    # Ensure the user is authenticated before checking user-specific conditions
    if user_signed_in?
      unless @designer.validation || current_user.admin? || @designer.user == current_user
        redirect_to root_path, notice: "Vous n'avez pas l'autorisation d'accéder à ce designer."
      end
      @lists = current_user.lists
    else
      unless @designer.validation
        redirect_to root_path, notice: "Vous n'avez pas l'autorisation d'accéder à ce designer."
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

  end

  # POST /designers or /designers.json
  def create
    @designer = current_user.designers.build(designer_params)

    respond_to do |format|
      if @designer.save
        update_suivi_references_emises(current_user)
        create_notification(@designer)
        format.html { redirect_to designer_url(@designer), notice: "Designer ajouté(e)" }
        format.json { render :show, status: :created, location: @designer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @designer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /designers/1 or /designers/1.json
  def update
    respond_to do |format|
      if @designer.update(designer_params)
        format.html { redirect_to designer_url(@designer), notice: "Référence mise à jour" }
        format.json { render :show, status: :ok, location: @designer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @designer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /designers/1 or /designers/1.json
  def destroy
    @designer.destroy!

    respond_to do |format|
      update_suivi_references_refusees(@designer.user)
      format.html { redirect_to validation_path, notice: "Le designer " + @designer.nom_designer + " a été supprimée avec succès." }
      format.json { head :no_content }
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
      redirect_to validation_path, notice: "Le/La designer " + @designer.nom_designer + " a été validée avec succès."
    else
      redirect_to validation_path, alert: "Une erreur s'est produite lors de la validation du designer."
    end
  end

  private

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
    suivi.increment(:nb_references_refusees)  # Correction de l'attribut
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
    message = "Le/La designer #{designer.nom_designer} a été validée. Encore un grand merci pour ta contribution"
    if designer.user_id.present?
      Notification.create(user_id: designer.user_id, notifiable: designer, message: message)
    else
      Notification.create(notifiable: designer, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    Rails.logger.error("Erreur lors de la création de la notification : #{e.message}")
  end

  def set_designer
    @designer = Designer.friendly.find(params[:slug])
  end

  def designer_params
    params.require(:designer).permit(:nom_designer, :date_naissance, :image, :presentation_generale, :country_id, :date_deces)
  end
end
