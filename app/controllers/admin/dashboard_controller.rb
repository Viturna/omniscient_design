class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @current_page = 'dashboard'
    
    # --- Statistiques des cartes ---
    @new_users_this_week = User.where(created_at: 1.week.ago..Time.current).count
    @avg_visits_30d = calculate_avg_visits(30.days.ago)
    @avg_visits_12m = calculate_avg_visits(12.months.ago)
    @nb_etablissements_actifs = User.joins(:etablissement).distinct.count('etablissements.id')
    @notifications = Notification.where(user: current_user).order(created_at: :desc).limit(5)

    # --- Graphique : Nouvelles Inscriptions (User) ---
    @period = params[:period] || '30d'
    end_date = Date.today

    if @period == '12m'
      start_date = 12.months.ago.to_date
      # Récupération et groupement manuel
      users_data = User.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                       .pluck(:created_at)
      
      grouped_data = users_data.group_by { |d| d.beginning_of_month.to_date }
      
      months_range = (start_date..end_date).map { |d| d.beginning_of_month.to_date }.uniq
      @users_over_time = months_range.map do |date|
        [date.strftime("%b %Y"), grouped_data[date]&.count || 0]
      end

    else # 7d ou 30d
      start_date = (@period == '7d' ? 7.days.ago : 30.days.ago).to_date
      
      users_data = User.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                       .pluck(:created_at)
      
      grouped_data = users_data.group_by { |d| d.to_date }
      
      @users_over_time = (start_date..end_date).map do |date|
        [date.strftime("%d/%m"), grouped_data[date]&.count || 0]
      end
    end
  end

  def suivi_references
    @current_page = 'suivi_references'
    @suivis = Suivi.includes(:user).all
  end

  def suivi_lists
    @current_page = 'suivi_lists'
    @total_lists = List.count
    @users_with_lists = User.joins(:lists).distinct.count
    @total_visitors = ListVisitor.count
    @total_editors = ListEditor.count

    @top_creators = User
      .select("users.id, users.firstname, users.lastname, users.email, COUNT(lists.id) AS lists_count")
      .joins(:lists)
      .group("users.id, users.firstname, users.lastname, users.email")
      .order("lists_count DESC")
      .page(params[:creators_page]).per(20)

    @top_invited = User
      .select("users.id, users.firstname, users.lastname, users.email, COUNT(list_visitors.id) AS invites_count")
      .joins(:list_visitors)
      .group("users.id, users.firstname, users.lastname, users.email")
      .order("invites_count DESC")
      .page(params[:invited_page]).per(20)
  end

  private

  def authenticate_admin!
    redirect_to root_path, alert: "Accès interdit." unless current_user&.admin?
  end

  def calculate_avg_visits(since_date)
    visits = DailyVisit.joins(:user).where.not(users: { role: 'admin' }).where('daily_visits.visited_on >= ?', since_date)
    unique_users = visits.distinct.count(:user_id)
    unique_users > 0 ? (visits.count.to_f / unique_users).round(1) : 0
  end
end