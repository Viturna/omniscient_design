class DomainesController < ApplicationController
  before_action :set_domaine, only: %i[ show edit update destroy ]

  # GET /domaines or /domaines.json
  def index
    @domaines = Domaine.all
  end

  # GET /domaines/1 or /domaines/1.json
  def show
  end

  # GET /domaines/new
  def new
    @domaine = Domaine.new
  end

  # GET /domaines/1/edit
  def edit
  end

  # POST /domaines or /domaines.json
  def create
    @domaine = Domaine.new(domaine_params)

    respond_to do |format|
      if @domaine.save
        format.html { redirect_to domaine_url(@domaine), notice: "Domaine was successfully created." }
        format.json { render :show, status: :created, location: @domaine }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domaine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domaines/1 or /domaines/1.json
  def update
    respond_to do |format|
      if @domaine.update(domaine_params)
        format.html { redirect_to domaine_url(@domaine), notice: "Domaine was successfully updated." }
        format.json { render :show, status: :ok, location: @domaine }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domaine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domaines/1 or /domaines/1.json
  def destroy
    @domaine.destroy!

    respond_to do |format|
      format.html { redirect_to domaines_url, notice: "Domaine was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domaine
      @domaine = Domaine.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def domaine_params
      params.require(:domaine).permit(:domaine, :couleur)
    end
end
