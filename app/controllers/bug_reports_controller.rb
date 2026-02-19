class BugReportsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :authenticate_admin!, only: [:index, :show, :destroy, :update_status]
  before_action :set_bug_report, only: [:show, :destroy, :update_status]
  layout 'admin', only: [:index]

  def index
    @current_page = 'bug_reports'

    # --- 1. KPIs ---
    @total_bugs = BugReport.count
    @bugs_todo = BugReport.where(status: 'a_faire').count
    @bugs_in_progress = BugReport.where(status: 'en_cours').count
    @bugs_resolved = BugReport.where(status: 'corrige').count

    # --- 2. GRAPHIQUE ÉVOLUTION ---
    # Par défaut sur 6 mois, groupé par mois
    start_date = 6.months.ago.to_date
    @evolution_bugs = BugReport.where("created_at >= ?", start_date)
                               .group_by_month(:created_at, format: "%b %Y")
                               .count

    # --- 3. GRAPHIQUE RÉPARTITION ---
    # Utilisation des clés de l'enum ou traduction
    @repartition_status = {
      "À faire" => @bugs_todo,
      "En cours" => @bugs_in_progress,
      "Corrigé" => @bugs_resolved
    }

    # --- 4. TABLEAU PRINCIPAL ---
    # Includes :user pour éviter les requêtes N+1
    @bug_reports = BugReport.includes(:user)
                            .order(created_at: :desc)
                            .page(params[:page]).per(20)
  end

  def new
    @current_page = 'profil'
    @bug_report = BugReport.new
  end

  def create
    @bug_report = BugReport.new(bug_report_params)
    @bug_report.user = current_user
    
    # Check investigator (Gamification)
    GamificationService.new(current_user).check_investigator

    if @bug_report.save
      notify_admins_of_new_bug(@bug_report)
      redirect_to profil_path, notice: I18n.t('bug_report.create.success')
    else
      render :new
    end
  end

  def show
    @current_page = 'profil'
  end

  def destroy
    @bug_report.destroy
    redirect_to bug_reports_path, notice: I18n.t('bug_report.destroy.success')
  end

  def update_status
    # On convertit le paramètre en integer si l'enum est stocké en integer, 
    # ou on passe la string si c'est stocké en string. 
    # Rails gère souvent ça tout seul, mais attention aux conversions.
    new_status = params[:status]

    if @bug_report.update(status: new_status)
      notify_user_of_status_update(@bug_report)
      redirect_to bug_reports_path, notice: I18n.t('bug_report.update_status.success')
    else
      redirect_to bug_reports_path, alert: I18n.t('bug_report.update_status.error')
    end
  end

  private

  def set_bug_report
    @bug_report = BugReport.find(params[:id])
  end

  def bug_report_params
    params.require(:bug_report).permit(:description, :url, :category)
  end

  def authenticate_admin!
    redirect_to root_path, alert: I18n.t('bug_report.access.denied') unless current_user&.admin?
  end

  def notify_admins_of_new_bug(bug_report)
    title = "Nouveau bug signalé"
    message = I18n.t('notifications.new_bug_report', 
                     user_name: bug_report.user.pseudo, 
                     default: "Nouveau bug signalé par #{bug_report.user.pseudo}.")

    User.where(role: 'admin').each do |user| 
      Notification.create(user_id: user.id, notifiable: bug_report, title: title, message: message, status: :unread)
    end
  rescue => e
    Rails.logger.error "ERREUR notify_admins_of_new_bug: #{e.message}"
  end

  def notify_user_of_status_update(bug_report)
    return unless bug_report.user.present?
    return if bug_report.user == current_user && current_user.admin?

    title = "Suivi de votre signalement"
    # Traduction propre du statut
    status_key = bug_report.status
    status_text = I18n.t("enums.bug_report.status.#{status_key}", default: status_key.humanize)
    
    message = "Votre rapport est passé au statut : #{status_text}"
                     
    Notification.create(user: bug_report.user, notifiable: bug_report, title: title, message: message, status: :unread)
  rescue => e
    Rails.logger.error "ERREUR notify_user_of_status_update: #{e.message}"
  end
end