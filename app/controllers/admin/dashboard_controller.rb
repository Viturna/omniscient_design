class Admin::DashboardController <  ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin! 
  def index
    @current_page = 'dashboard'
    @users = User.all
    @nb_etablissements_actifs = User.joins(:etablissement).distinct.count('etablissements.id')

   # 7 derniers jours
    visits_7d = DailyVisit.joins(:user)
                          .where.not(users: { role: 'admin' })
                          .where('daily_visits.visited_on >= ?', 7.days.ago)
    
    unique_users_7d = visits_7d.distinct.count(:user_id)
    @avg_visits_7d = unique_users_7d > 0 ? (visits_7d.count.to_f / unique_users_7d).round(1) : 0

    # 30 derniers jours (Mois)
    visits_30d = DailyVisit.joins(:user)
                           .where.not(users: { role: 'admin' })
                           .where('daily_visits.visited_on >= ?', 30.days.ago)
                           
    unique_users_30d = visits_30d.distinct.count(:user_id)
    @avg_visits_30d = unique_users_30d > 0 ? (visits_30d.count.to_f / unique_users_30d).round(1) : 0

    # 12 derniers mois (Année)
    visits_12m = DailyVisit.joins(:user)
                           .where.not(users: { role: 'admin' })
                           .where('daily_visits.visited_on >= ?', 12.months.ago)
                           
    unique_users_12m = visits_12m.distinct.count(:user_id)
    @avg_visits_12m = unique_users_12m > 0 ? (visits_12m.count.to_f / unique_users_12m).round(1) : 0
  end

  def suivi_references
    @current_page = 'suivi_references'
    @suivis = Suivi.includes(:user).all
  end


  def suivi_lists
    @current_page = 'suivi_lists'
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
