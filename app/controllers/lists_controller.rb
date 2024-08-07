class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = current_user.lists
   @current_page = 'listes'
  end

  def show
  end

  def new
    @list = current_user.lists.build
  end

  def create
    @list = current_user.lists.build(list_params)

    if @list.save
      redirect_to @list, notice: 'Liste créée avec succès.'
    else
      render :new
    end
  end

  def edit
    # Afficher le formulaire de modification de la liste
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: 'Liste mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_url, notice: 'Liste supprimée avec succès.'
  end
  def add_oeuvre
    @list = List.find(params[:list_id])
    @oeuvre = Oeuvre.find(params[:artwork_id])

    if @list && @oeuvre
      if @list.oeuvres.exists?(@oeuvre.id)
        redirect_to @oeuvre, notice: "L'oeuvre est déjà dans la liste."
      else
        @list.oeuvres << @oeuvre
        redirect_to @oeuvre, notice: "L'oeuvre a été ajoutée à la liste."
      end
    else
      redirect_to @oeuvre, notice: "Impossible d'ajouter l'oeuvre à la liste."
    end
  end
  def remove_oeuvre
    @list = List.find(params[:id])
    @oeuvre = Oeuvre.find(params[:oeuvre_id])

    if @list && @oeuvre
      if @list.oeuvres.exists?(@oeuvre.id)
        @list.oeuvres.delete(@oeuvre)
        redirect_to request.referer, notice: "L'oeuvre a été retiré(e) de la liste."
      else
        redirect_to request.referer, notice: "L'oeuvre n'est pas dans la liste."
      end
    else
      redirect_to request.referer, notice: "Impossible de retirer l'oeuvre de la liste."
    end
  end

  def add_designer
    @list = List.find(params[:list_id])
    @designer = Designer.find(params[:artwork_id])

    if @list && @designer
      if @list.designers.exists?(@designer.id)
        redirect_to @designer, notice: "Le/La designer est déjà dans la liste."
      else
        @list.designers << @designer
        redirect_to @designer, notice: "Le/La designer a été ajoutée à la liste."
      end
    else
      redirect_to @designer, notice: "Impossible d'ajouter le/la designer à la liste."
    end
  end
  def remove_designer
    @list = List.find(params[:id])
    @designer = Designer.find(params[:designer_id])

    if @list && @designer
      if @list.designers.exists?(@designer.id)
        @list.designers.delete(@designer)
        redirect_to request.referer, notice: "Le/La designer a été retiré(e) de la liste."
      else
        redirect_to request.referer, notice: "Le/La designer n'est pas dans la liste."
      end
    else
      redirect_to request.referer, notice: "Impossible de retirer le/la designer de la liste."
    end
  end





  private

  def set_list
    @list = current_user.lists.find_by(id: params[:id])
    if @list.nil?
      # Gérer le cas où la liste n'est pas trouvée
      redirect_to lists_path, alert: "List not found or you don't have access to it."
    end
  end

  def list_params
    params.require(:list).permit(:name, designer_ids: [], oeuvre_ids: [])
  end
end
