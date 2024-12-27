class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy, :invite_editors, :change_role, :remove_user, :toggle_privacy, :remove_designer,:remove_oeuvre, :add_oeuvre, :add_designer]

  def index
    @lists = current_user.lists
    @editor_lists = current_user.editable_lists
    @visitor_lists = current_user.visitor_lists
    @current_page = 'listes'
  end

  def show
    @current_page = 'listes'
    @list = List.friendly.find(params[:slug])
    if @list.share_token.present? && @list.share_token == params[:share_token]
      render :show
    elsif @list.user == current_user || @list.editors.include?(current_user) || @list.visitors.include?(current_user)
      render :show
    else
      redirect_to root_path, alert: "Cette liste n'existe pas ou n'est pas partagée."
    end
  end

  def shared
    @list = List.find_by(share_token: params[:share_token])
    if @list
      render :show
    else
      redirect_to root_path, alert: "Cette liste n'existe pas ou n'est pas partagée."
    end
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

  def remove_designer
    designer = Designer.find(params[:designer_id])
    if @list.designers.delete(designer)
      notice = "Designer retiré avec succès."
    else
      notice = "Erreur lors du retrait du designer."
    end
    redirect_to @list, notice: notice
  end

  def remove_oeuvre
    oeuvre = Oeuvre.find(params[:oeuvre_id])
    if @list.oeuvres.delete(oeuvre)
      notice = "Référence retirée avec succès."
    else
      notice = "Erreur lors du retrait de la référence."
    end
    redirect_to @list, notice: notice
  end

  def add_oeuvre
    oeuvre = Oeuvre.find(params[:artwork_id])

    if @list.oeuvres << oeuvre
      redirect_to request.referer, notice: "Référence ajoutée avec succès."
    else
      redirect_to request.referer, alert: "Impossible d'ajouter la référence."
    end
  end

  def add_designer
    designer = Designer.find(params[:designer_id])
    if @list.designers << designer
      redirect_to request.referer, notice: "Designer ajouté avec succès."
    else
      redirect_to request.referer, alert: "Impossible d'ajouter le designer."
    end
  end

  def toggle_privacy
    if params[:privacy] == 'public'
      @list.update(share_token: @list.previous_share_token || SecureRandom.hex(10))
      notice = "La liste est maintenant publique."
    else
      @list.update(previous_share_token: @list.share_token, share_token: nil)
      notice = "La liste est maintenant privée."
    end
    redirect_to @list, notice: notice
  end

  def invite_editors
    user = User.find_by(email: params[:email])
    role = params[:role]

    if user
      if role == 'editor'
        @list.editors << user unless @list.editors.include?(user)
      elsif role == 'visitor'
        @list.visitors << user unless @list.visitors.include?(user)
      end

      # Assurez-vous que le share_token est défini
      @list.update(share_token: SecureRandom.hex(10)) unless @list.share_token.present?

      ListMailer.invite_editor(@list, user).deliver_now
      redirect_to @list, notice: "Utilisateur invité avec succès."
    else
      redirect_to @list, alert: "Utilisateur introuvable."
    end
  end

  def change_role
    user = User.find(params[:user_id])
    role = params[:role]

    if role == 'remove'
      if @list.editors.delete(user) || @list.visitors.delete(user)
        notice = "Utilisateur supprimé avec succès."
      else
        notice = "Erreur lors de la suppression de l'utilisateur."
      end
    elsif role == 'editor'
      @list.editors << user unless @list.editors.include?(user)
      @list.visitors.delete(user)
      notice = "Utilisateur désigné comme éditeur."
    elsif role == 'visitor'
      @list.visitors << user unless @list.visitors.include?(user)
      @list.editors.delete(user)
      notice = "Utilisateur désigné comme visiteur."
    else
      notice = "Rôle invalide."
    end

    redirect_to @list, notice: notice
  end

  def remove_user
    user = User.find(params[:user_id])
    if @list.editors.exists?(user.id)
      @list.editors.delete(user)
      notice = "Utilisateur supprimé avec succès."
    elsif @list.visitors.exists?(user.id)
      @list.visitors.delete(user)
      notice = "Utilisateur supprimé avec succès."
    else
      notice = "Erreur lors de la suppression de l'utilisateur."
    end
    redirect_to @list, notice: notice
  end

  private

  def set_list
    @list = List.friendly.find(params[:slug])
    if @list.nil?
      redirect_to lists_path, alert: "List not found or you don't have access to it."
    end
  end

  def list_params
    params.require(:list).permit(:name, designer_ids: [], oeuvre_ids: [])
  end
end
