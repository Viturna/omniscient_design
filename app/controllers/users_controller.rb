class UsersController < ApplicationController
  layout 'admin', only: %i[index show]
  before_action :set_user, only: %i[ban unban]
  before_action :check_admin_role,
                only: %i[index certify uncertify admin_resend_confirmation ban unban export_newsletter]

  def index
    @current_page = 'users'

    # --- 1. Gestion de la Période (Filtre Temporel) ---
    @period = params[:period] || '30d'

    if params[:start_date].present? && params[:end_date].present?
      @period = 'custom'
      begin
        start_d = Date.parse(params[:start_date])
        end_d = Date.parse(params[:end_date])
        range = start_d..end_d
        if (end_d - start_d) > 90
          date_format = '%b %Y'
          @group_by = :month
        else
          date_format = '%d/%m'
          @group_by = :day
        end
      rescue ArgumentError
        range = 30.days.ago.to_date..Date.today
        date_format = '%d/%m'
        @group_by = :day
      end
    else
      # Configuration des plages de dates selon le bouton cliqué
      case @period
      when '7d'
        range = 7.days.ago.to_date..Date.today
        date_format = '%d/%m'
        @group_by = :day
      when '60d'
        range = 60.days.ago.to_date..Date.today
        date_format = '%d/%m'
        @group_by = :day
      when '90d'
        range = 90.days.ago.to_date..Date.today
        date_format = '%d/%m'
        @group_by = :day
      when '12m'
        range = 12.months.ago.to_date..Date.today
        date_format = '%b %Y'
        @group_by = :month
      else # '30d' par défaut
        range = 30.days.ago.to_date..Date.today
        date_format = '%d/%m'
        @group_by = :day
      end
    end

    # --- 2. Données pour les Graphiques Principaux ---

    # Graphique 1 : Évolution des Inscriptions (User)
    users_data = User.where(created_at: range.first.beginning_of_day..range.last.end_of_day)
                     .pluck(:created_at)

    if @group_by == :month
      grouped_users = users_data.group_by { |d| d.beginning_of_month.to_date }
      timeline = (range.first..range.last).map { |d| d.beginning_of_month.to_date }.uniq
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
      val = if @group_by == :month
              # Somme des visites du mois
              DailyVisit.where(visited_on: date.beginning_of_month..date.end_of_month).count
            else
              visits_data[date] || 0
            end
      [date.strftime(date_format), val]
    end

    # Graphique 3 : Évolution des Acquisitions
    acq_data = User.where(created_at: range.first.beginning_of_day..range.last.end_of_day)
                   .where.not(how_did_you_hear: [nil, ""])
                   .pluck(:created_at, :how_did_you_hear)
    
    @chart_acquisition = acq_data.group_by(&:last).map do |source, items|
      if @group_by == :month
        grouped = items.map(&:first).group_by { |d| d.beginning_of_month.to_date }
      else
        grouped = items.map(&:first).group_by { |d| d.to_date }
      end
      data = timeline.map do |date|
        [date.strftime(date_format), grouped[date]&.count || 0]
      end
      { name: source, data: data }
    end

    @newsletter_count = User.where(newsletter: true).count
    # --- 3. Statistiques Globales & KPIs ---
    @total_users = User.count # Total indépendant de la période
    @new_users_period = User.where(created_at: range.first.beginning_of_day..range.last.end_of_day).count
    @active_users_period = DailyVisit.where(visited_on: range).distinct.count(:user_id)

    # Graphiques secondaires (Données globales)
    @distrib_statut = User.group(:statut).count
    @distrib_acquisition = User.where.not(how_did_you_hear: [nil,
                                                             '']).group(:how_did_you_hear).count.sort_by do |_k, v|
      -v
    end.to_h
    @distrib_levels = User.where.not(study_level: [nil, '']).group(:study_level).count.sort_by { |_k, v| -v }.to_h

    # --- 4. Tableau & Filtres ---
    @users = User.all
    if params[:query].present?
      sql = 'firstname ILIKE :q OR lastname ILIKE :q OR email ILIKE :q OR pseudo ILIKE :q'
      @users = @users.where(sql, q: "%#{params[:query]}%")
    end
    @users = @users.where(statut: params[:statut]) if params[:statut].present?
    @users = @users.where(role: params[:role]) if params[:role].present?

    # Filtre par tranche de visites
    if params[:visits].present?
      visits_subquery = DailyVisit.select(:user_id)
                                  .group(:user_id)
                                  .having(
                                    case params[:visits]
                                    when '0'   then 'COUNT(*) = 0'
                                    when '1-5' then 'COUNT(*) BETWEEN 1 AND 5'
                                    when '5-20' then 'COUNT(*) BETWEEN 5 AND 20'
                                    when '20+' then 'COUNT(*) > 20'
                                    end
                                  )
      @users = if params[:visits] == '0'
                 @users.where.not(id: DailyVisit.select(:user_id).distinct)
               else
                 @users.where(id: visits_subquery)
               end
    end

    # --- 5. Tri des utilisateurs ---
    sort_param = params[:sort]
    if sort_param.present?
      case sort_param
      when 'etablissement_asc'
        @users = @users.left_outer_joins(:etablissement).order(Arel.sql('etablissements.name ASC NULLS LAST'))
      when 'etablissement_desc'
        @users = @users.left_outer_joins(:etablissement).order(Arel.sql('etablissements.name DESC NULLS LAST'))
      when 'nom_asc'
        @users = @users.order(firstname: :asc, lastname: :asc)
      when 'nom_desc'
        @users = @users.order(firstname: :desc, lastname: :desc)
      when 'inscription_asc'
        @users = @users.order(created_at: :asc)
      when 'inscription_desc'
        @users = @users.order(created_at: :desc)
      when 'etablissement'
        direction = params[:direction] == 'desc' ? 'DESC' : 'ASC'
        @users = @users.left_outer_joins(:etablissement).order(Arel.sql("etablissements.name #{direction} NULLS LAST"))
      when 'utilisateur'
        direction = params[:direction] == 'desc' ? :desc : :asc
        @users = @users.order(firstname: direction, lastname: direction)
      when 'statut'
        direction = params[:direction] == 'desc' ? :desc : :asc
        @users = @users.order(statut: direction)
      when 'study_level'
        direction = params[:direction] == 'desc' ? :desc : :asc
        @users = @users.order(study_level: direction)
      when 'inscription'
        direction = params[:direction] == 'desc' ? :desc : :asc
        @users = @users.order(created_at: direction)
      when 'visites', 'visites_asc', 'visites_desc'
        direction = sort_param == 'visites_desc' || (sort_param == 'visites' && params[:direction] == 'desc') ? 'DESC' : 'ASC'
        @users = @users
                 .select('users.*, COALESCE(v.visits_count, 0) AS visits_count')
                 .joins('LEFT JOIN (SELECT user_id, COUNT(*) AS visits_count FROM daily_visits GROUP BY user_id) v ON v.user_id = users.id')
                 .order(Arel.sql("COALESCE(v.visits_count, 0) #{direction}"))
      else
        @users = @users.order(created_at: :desc)
      end
    else
      @users = @users.order(created_at: :desc)
    end

    @paginated_users = @users.includes(:etablissement, profile_image_attachment: :blob).page(params[:page]).per(20)
    @users_for_map = @users.includes(:etablissement).where.not(etablissement_id: nil)
  end

  def show
    @current_page = 'users'
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
      redirect_to user_path(@user),
                  alert: I18n.t('user.access.denied_admin', default: "Tu n'as pas les permissions nécessaires.")
    end
  end

  def unban
    if current_user.admin? && @user.banned?
      @user.update(banned: false)
      flash[:notice] = I18n.t('user.unbanned_success', default: "L'utilisateur a été débanni.")
    else
      flash[:alert] = I18n.t('user.unbanned_denied', default: 'Tu ne peux pas débannir cet utilisateur.')
    end
    redirect_to user_path(@user)
  end

  def certify
    user = User.find(params[:id])
    if user.update(certified: true)
      flash[:notice] =
        I18n.t('user.certified_success', name: user.firstname,
                                         default: "#{user.firstname} a été certifié avec succès.")
    else
      flash[:alert] = I18n.t('user.certified_failure', default: 'Une erreur est survenue lors de la certification.')
    end
    redirect_to user_path(@user)
  end

  def uncertify
    user = User.find(params[:id])
    if user.update(certified: false)
      flash[:notice] =
        I18n.t('user.uncertified_success', name: user.firstname,
                                           default: "La certification de #{user.firstname} a été retirée avec succès.")
    else
      flash[:alert] =
        I18n.t('user.uncertified_failure', default: 'Une erreur est survenue lors du retrait de la certification.')
    end
    redirect_to user_path(@user)
  end

  def admin_resend_confirmation
    @user = User.find(params[:id])

    if @user.confirmed?
      redirect_to users_path, alert: 'Cet utilisateur a déjà confirmé son compte.'
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

  def export_newsletter
    require 'csv'
    @newsletter_users = User.where(newsletter: true).order(created_at: :desc)

    csv_data = CSV.generate(col_sep: ';', force_quotes: true) do |csv|
      csv << ['ID', 'Prénom', 'Nom', 'Email', 'Pseudo', 'Statut', 'Établissement', "Date d'inscription"]
      @newsletter_users.each do |user|
        csv << [
          user.id,
          user.firstname,
          user.lastname,
          user.email,
          user.pseudo,
          user.statut,
          user.etablissement&.name,
          user.created_at.strftime('%d/%m/%Y %H:%M:%S')
        ]
      end
    end

    send_data csv_data, filename: "newsletter_users_#{Date.today}.csv", type: 'text/csv'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
