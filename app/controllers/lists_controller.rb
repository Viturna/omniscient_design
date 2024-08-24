class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    @lists = current_user.lists
    @current_page = 'listes'
  end

  def show
    @current_page = 'listes'
  end

  def new
    @current_page = 'listes'
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
    @current_page = 'listes'
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
        redirect_to @oeuvre, notice: "La référence est déjà dans la liste."
      else
        @list.oeuvres << @oeuvre
        redirect_to @oeuvre, notice: "La référence a été ajoutée à la liste."
      end
    else
      redirect_to @oeuvre, notice: "Impossible d'ajouter la référence à la liste."
    end
  end
  def remove_oeuvre
    @list = List.find(params[:id])
    @oeuvre = Oeuvre.find(params[:oeuvre_id])

    if @list && @oeuvre
      if @list.oeuvres.exists?(@oeuvre.id)
        @list.oeuvres.delete(@oeuvre)
        redirect_to request.referer, notice: "La référence a été retirée de la liste."
      else
        redirect_to request.referer, notice: "La référence n'est pas dans la liste."
      end
    else
      redirect_to request.referer, notice: "Impossible de retirer la référence de la liste."
    end
  end

  def add_designer
    @list = List.find(params[:list_id])
    @designer = Designer.find(params[:artwork_id])

    if @list && @designer
      if @list.designers.exists?(@designer.id)
        redirect_to @designer, notice: "La référence est déjà dans la liste."
      else
        @list.designers << @designer
        redirect_to @designer, notice: "La référence a été ajoutée à la liste."
      end
    else
      redirect_to @designer, notice: "Impossible d'ajouter la référence à la liste."
    end
  end
  def remove_designer
    @list = List.find(params[:id])
    @designer = Designer.find(params[:designer_id])

    if @list && @designer
      if @list.designers.exists?(@designer.id)
        @list.designers.delete(@designer)
        redirect_to request.referer, notice: "La référence a été retirée de la liste."
      else
        redirect_to request.referer, notice: "La référence n'est pas dans la liste."
      end
    else
      redirect_to request.referer, notice: "Impossible de retirer la référence de la liste."
    end
  end

  private

  def set_list
    @list = current_user.lists.friendly.find(params[:slug])
    if @list.nil?
      # Gérer le cas où la liste n'est pas trouvée
      redirect_to lists_path, alert: "List not found or you don't have access to it."
    end
  end

  def list_params
    params.require(:list).permit(:name, designer_ids: [], oeuvre_ids: [])
  end
end
