class Admin::DashboardController <  ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin! 
  def index
    @current_page = 'dashboard'
    @users = User.all
  end

  def suivi_references
    @current_page = 'suivi_references'
    @suivis = Suivi.includes(:user).all
  end


  def suivi_lists
    # --- Statistiques globales (inchangées) ---
    @total_lists = List.count
    @users_with_lists = User.joins(:lists).distinct.count
    @total_visitors = ListVisitor.count
    @total_editors = ListEditor.count

    @top_creators = User
      .select("users.id, users.firstname, users.lastname, users.email, COUNT(lists.id) AS lists_count")
      .joins(:lists)
      .group("users.id, users.firstname, users.lastname, users.email") # Doit inclure tous les champs non agrégés
      .order("lists_count DESC")
      .page(params[:creators_page]).per(20) # Pagination Kaminari

    # --- Classement paginé des utilisateurs invités ---
    @top_invited = User
      .select("users.id, users.firstname, users.lastname, users.email, COUNT(list_visitors.id) AS invites_count")
      .joins(:list_visitors)
      .group("users.id, users.firstname, users.lastname, users.email") # Doit inclure tous les champs non agrégés
      .order("invites_count DESC")
      .page(params[:invited_page]).per(20) # Pagination Kaminari
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end
