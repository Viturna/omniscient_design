class UsersController < ApplicationController
    layout 'admin', only: [:index, :show]
  before_action :set_user, only: [:ban, :unban]
  before_action :check_admin_role, only: [:index, :certify, :uncertify, :admin_resend_confirmation, :ban, :unban]

 def index
    @current_page = "users"
    
    # --- 1. Gestion de la Période (Filtre Temporel) ---
    @period = params[:period] || '30d'
    
    # Configuration des plages de dates selon le bouton cliqué
    case @period
    when '7d'
      range = 7.days.ago.to_date..Date.today
      date_format = "%d/%m"
    when '60d'
      range = 60.days.ago.to_date..Date.today
      date_format = "%d/%m"
    when '90d'
      range = 90.days.ago.to_date..Date.today
      date_format = "%d/%m"
    when '12m'
      range = 12.months.ago.to_date..Date.today
      date_format = "%b %Y"
    else # '30d' par défaut
      range = 30.days.ago.to_date..Date.today
      date_format = "%d/%m"
    end

    # --- 2. Données pour les Graphiques Principaux ---
    
    # Graphique 1 : Évolution des Inscriptions (User)
    users_data = User.where(created_at: range.first.beginning_of_day..range.last.end_of_day)
                     .pluck(:created_at)
    
    if @period == '12m'
      grouped_users = users_data.group_by { |d| d.beginning_of_month.to_date }
      timeline = range.map { |d| d.beginning_of_month }.uniq
    else
      grouped_users = users_data.group_by { |d| d.to_date }
      timeline = range.to_a
    end
    
    @chart_signups = timeline.map { |date| [date.strftime(date_format), grouped_users[date]&.count || 0] }

    # Graphique 2 : Évolution des Visites (DailyVisit)
    visits_data = DailyVisit.where(visited_on: range)
                            .group(:visited_on)
                            .count
    
    @chart_visits = timeline.map do |date| 
      val = if @period == '12m'
              # Somme des visites du mois
              DailyVisit.where(visited_on: date.beginning_of_month..date.end_of_month).count
            else
              visits_data[date] || 0
            end
      [date.strftime(date_format), val]
    end

    @newsletter_count = User.where(newsletter: true).count
    # --- 3. Statistiques Globales & KPIs ---
    @total_users = User.count # Total indépendant de la période
    @new_users_period = User.where(created_at: range.first.beginning_of_day..range.last.end_of_day).count
    @active_users_period = DailyVisit.where(visited_on: range).distinct.count(:user_id)
    @certified_count = User.where(certified: true).count

    # Graphiques secondaires (Données globales)
    @distrib_statut = User.group(:statut).count
    @distrib_acquisition = User.where.not(how_did_you_hear: [nil, ""]).group(:how_did_you_hear).count
    @distrib_levels = User.where.not(study_level: [nil, ""]).group(:study_level).count

    # --- 4. Tableau & Filtres ---
    @users = User.all
    if params[:query].present?
      sql = "firstname ILIKE :q OR lastname ILIKE :q OR email ILIKE :q OR pseudo ILIKE :q"
      @users = @users.where(sql, q: "%#{params[:query]}%")
    end
    @users = @users.where(statut: params[:statut]) if params[:statut].present?
    @users = @users.where(role: params[:role]) if params[:role].present?

    @paginated_users = @users.order(created_at: :desc).page(params[:page]).per(20)
    @users_for_map = @users.includes(:etablissement).where.not(etablissement_id: nil)
  end

 def show
    @user = User.find(params[:id])
  
    @total_visits = @user.daily_visits.count
    @last_visit = @user.daily_visits.order(visited_on: :desc).first&.visited_on
    
    @lists_count = @user.respond_to?(:lists) ? @user.lists.count : 0

    @user_activity = DailyVisit.where(user: @user)
                               .group_by_day(:visited_on, range: 30.days.ago..Date.today)
                               .count

    @badges = @user.badges if @user.respond_to?(:badges)
  end
  def visits
    @user = User.find(params[:id])
    @visits = @user.daily_visits.order(created_at: :desc).page(params[:page]).per(50)
  end
  def ban
    if current_user.admin?
      @user.update(banned: true)
      redirect_to user_path(@user), notice: I18n.t('user.banned_success', default: 'Utilisateur banni avec succès.')
    else
      redirect_to user_path(@user), alert: I18n.t('user.access.denied_admin', default: "Vous n'avez pas les permissions nécessaires.")
    end
  end
  def unban
    if current_user.admin? && @user.banned?
      @user.update(banned: false)
      flash[:notice] = I18n.t('user.unbanned_success', default: "L'utilisateur a été débanni.")
    else
      flash[:alert] = I18n.t('user.unbanned_denied', default: "Vous ne pouvez pas débannir cet utilisateur.")
    end
    redirect_to user_path(@user)
  end

  def certify
    user = User.find(params[:id])
    if user.update(certified: true)
      flash[:notice] = I18n.t('user.certified_success', name: user.firstname, default: "#{user.firstname} a été certifié avec succès.")
    else
      flash[:alert] = I18n.t('user.certified_failure', default: "Une erreur est survenue lors de la certification.")
    end
    redirect_to user_path(@user)
  end

  def uncertify
    user = User.find(params[:id])
    if user.update(certified: false)
      flash[:notice] = I18n.t('user.uncertified_success', name: user.firstname, default: "La certification de #{user.firstname} a été retirée avec succès.")
    else
      flash[:alert] = I18n.t('user.uncertified_failure', default: "Une erreur est survenue lors du retrait de la certification.")
    end
    redirect_to user_path(@user)
  end

  def admin_resend_confirmation
  @user = User.find(params[:id])
  
  if @user.confirmed?
    redirect_to users_path, alert: "Cet utilisateur a déjà confirmé son compte."
  else
    token = @user.send(:generate_confirmation_token)
    @user.confirmation_sent_at = Time.now.utc
    @user.save(validate: false) 

    Devise::Mailer.confirmation_instructions(
      @user, 
      token, 
      { template_path: 'users/mailer', template_name: 'reconfirmation_instructions' }
    ).deliver_now
    
    redirect_to users_path, notice: "Mail de relance envoyé à #{@user.email}."
  end
end
  private

  

  def set_user
    @user = User.find(params[:id])
  end

end
