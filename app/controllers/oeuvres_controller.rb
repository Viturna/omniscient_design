class OeuvresController < ApplicationController
  before_action :set_oeuvre, only: %i[show edit update destroy validate cancel]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_admin_role, only: [:destroy, :validate]
  # GET /oeuvres or /oeuvres.json
  def index
    @oeuvres = Oeuvre.where(validation: true).limit(10).order("RANDOM()")
    @current_page = 'accueil'
    if user_signed_in?  # Vérifie si un utilisateur est connecté
      @lists = current_user.lists
    else
      @lists = []  # Si aucun utilisateur n'est connecté, initialise la variable @lists avec un tableau vide
    end
  end
  def load_more
    offset = params[:offset].to_i
    @oeuvres = Oeuvre.where(validation: true).offset(offset).limit(10).order("RANDOM()")
    render partial: 'oeuvres/card', collection: @oeuvres, as: :card
  end

  def search
    @current_page = 'recherche'
    @works = Oeuvre.pluck(:nom_oeuvre) # Utilisez Oeuvre à la place de Work

    # Date oeuvres
    @oeuvres = Oeuvre.where(validation: true).shuffle

    # Date oeuvres
    @oeuvres = Oeuvre.where(validation: true).shuffle
    @designers = Designer.where(validation: true).shuffle
    @start_year_oeuvre = params[:start_year_oeuvre].to_i.positive? ? params[:start_year_oeuvre].to_i : 1880
    @end_year_oeuvre = params[:end_year_oeuvre].to_i.positive? ? params[:end_year_oeuvre].to_i : 1889


    @timeline_years = (@start_year_oeuvre..@end_year_oeuvre).to_a
    @oeuvres_filtered = @oeuvres.select do |oeuvre|
      oeuvre.date_oeuvre.to_i.between?(@start_year_oeuvre, @end_year_oeuvre)
    end
    @designers_filtered = @designers.select do |designer|
      designer.date_naissance.to_i.between?(@start_year_oeuvre, @end_year_oeuvre)
    end
  end

  # GET /oeuvres/1 or /oeuvres/1.json
  def show
    # Ensure the user is authenticated before checking user-specific conditions
    if user_signed_in?
      unless @oeuvre.validation || current_user.admin? || @oeuvre.user == current_user
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette œuvre."
      end
      @lists = current_user.lists
    else
      unless @oeuvre.validation
        redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette œuvre."
      end
      @lists = []
    end
  end
  # GET /oeuvres/new
  def new
    @oeuvre = Oeuvre.new
    @current_page = 'add_elements'
  end

  # GET /oeuvres/1/edit
  def edit
    @oeuvre = Oeuvre.find(params[:id])
  end

  # POST /oeuvres or /oeuvres.json
  def create
    @oeuvre = current_user.oeuvres.build(oeuvre_params)

    respond_to do |format|
      if @oeuvre.save
        create_notification(@oeuvre)
        update_suivi_references_emises(current_user)
        format.html { redirect_to oeuvre_url(@oeuvre), notice: "Oeuvre ajoutée" }
        format.json { render :show, status: :created, location: @oeuvre }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @oeuvre.errors, status: :unprocessable_entity }
      end
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

  # DELETE /oeuvres/1 or /oeuvres/1.json
  def destroy
    @oeuvre.destroy!

    respond_to do |format|
      update_suivi_references_refusees(@oeuvre.user)
      format.html { redirect_to validation_path, notice: "L'oeuvre " + @oeuvre.nom_oeuvre + " a été supprimée avec succès." }
      format.json { head :no_content }
    end
  end
  def cancel
    if user_signed_in?
      if current_user.admin? || @oeuvre.user_id == current_user.id
        update_suivi_references_refusees(@oeuvre.user)
        @oeuvre.destroy!
        flash[:notice] = "La soumission de l'œuvre a été annulée avec succès."
        redirect_to oeuvres_path
      else
        flash[:notice] = "Vous n'avez pas l'autorisation d'annuler cette soumission."
        redirect_to oeuvres_path
      end
    end
  end
  def validate
    @oeuvre = Oeuvre.find(params[:id])
    if @oeuvre.update(validation: true, validated_by_user_id: current_user.id)
      create_validation_notification(@oeuvre)
      if @oeuvre.user.present?
        update_suivi_references_validees(@oeuvre.user)
        redirect_to validation_path, notice: "L'oeuvre " + @oeuvre.nom_oeuvre + " a été validée avec succès."
      else
        redirect_to validation_path, alert: "Utilisateur associé à l'œuvre non trouvé."
      end
    else
      redirect_to validation_path, alert: "Une erreur s'est produite lors de la validation de l'oeuvre."
    end
  end

  private
  def create_notification(oeuvre)
    message = "Une nouvelle oeuvre est à valider : #{oeuvre.nom_oeuvre}"
    admins = User.where(role: 'admin')
    admins.each do |admin|
      Notification.create(user_id: admin.id, notifiable: oeuvre, message: message)
    end
  end
  def create_validation_notification(oeuvre)
    message = "L'oeuvre #{oeuvre.nom_oeuvre} a été validée. Encore un grand merci pour ta contribution"

    # Vérifie si l'attribut user_id n'est pas vide dans l'objet oeuvre
    if oeuvre.user_id.present?
      Notification.create(user_id: oeuvre.user_id, notifiable: oeuvre, message: message)
    else
      # Créez la notification sans utilisateur associé
      Notification.create(notifiable: oeuvre, message: message)
    end
  rescue ActiveRecord::NotNullViolation => e
    # Gérez l'erreur ici, par exemple, en affichant un message ou en enregistrant les détails de l'erreur dans les journaux
    Rails.logger.error("Erreur lors de la création de la notification : #{e.message}")
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
    suivi.increment(:nb_references_refusees)  # Correction de l'attribut
    suivi.save
  end

  def set_oeuvre
    @oeuvre = Oeuvre.find(params[:id])
  end

  def oeuvre_params
    params.require(:oeuvre).permit(:domaine_id, :designer_id, :nom_oeuvre, :date_oeuvre, :description, :image)
  end
end
