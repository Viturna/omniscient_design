class BugReportsController < ApplicationController
  before_action :authenticate_user!, only: [:new]
  before_action :authenticate_admin!, only: [:index, :show, :destroy]
  before_action :set_bug_report, only: [:show, :destroy, :update_status]
  layout 'admin', only: [:index]

  def new
    @current_page = 'profil'
    @bug_report = BugReport.new
  end

  def create
    @bug_report = BugReport.new(bug_report_params)
    @bug_report.user = current_user
    notify_admins_of_new_bug(@bug_report)
    GamificationService.new(current_user).check_investigator
    if @bug_report.save
      redirect_to profil_path, notice: I18n.t('bug_report.create.success')
    else
      render :new
    end
  end

  def index
    @current_page = 'bug_reports'
    @bug_reports_all = BugReport.all
    @bug_reports_todo = BugReport.where(status: BugReport.statuses["a_faire"])
    @bug_reports_in_progress = BugReport.where(status: BugReport.statuses["en_cours"])
    @bug_reports_resolved = BugReport.where(status: BugReport.statuses["corrige"])

  end

  def show
    @current_page = 'profil'
    @bug_report = BugReport.find(params[:id])
  end

  def destroy
    @bug_report.destroy
    redirect_to bug_reports_path, notice: I18n.t('bug_report.destroy.success')
  end

def update_status
  if @bug_report.update(status: params[:status])
    redirect_to bug_reports_path, notice: I18n.t('bug_report.update_status.success')
    notify_user_of_status_update(@bug_report)
  else
    redirect_to bug_reports_path, alert: I18n.t('bug_report.update_status.error')
  end
end


  private

  def set_bug_report
    @bug_report = BugReport.find(params[:id])
  end

  def bug_report_params
    params.require(:bug_report).permit(:description, :url)
  end

  def authenticate_admin!
    redirect_to root_path, alert: I18n.t('bug_report.access.denied') unless current_user.admin?
  end

def notify_admins_of_new_bug(bug_report)
    title = "Nouveau bug signalé"
    message = I18n.t('notifications.new_bug_report', 
                     user_name: bug_report.user.pseudo, 
                     default: "Nouveau bug signalé par #{bug_report.user.pseudo} - Cliquer pour voir le rapport.")

    User.where(role: 'admin').each do |user| 
      Notification.create(
        user_id: user.id, 
        notifiable: bug_report, 
        title: title,
        message: message,

        status: :unread
      )
    end
  rescue => e
    Rails.logger.error "ERREUR notify_admins_of_new_bug: #{e.message}"
  end

  def notify_user_of_status_update(bug_report)
    return unless bug_report.user.present?
    return if bug_report.user == current_user && current_user.admin?

    title = "Suivi de votre signalement"
    status_text = I18n.t("bug_report.statuses.#{bug_report.status}", default: bug_report.status.humanize)
    
    message = I18n.t('notifications.bug_report_updated', 
                     status: status_text, 
                     default: "Votre rapport de bug est passé au statut : #{status_text}")
                     
    Notification.create(
      user: bug_report.user,
      notifiable: bug_report,
      title: title,  
      message: message,
      status: :unread
    )
  rescue => e
    Rails.logger.error "ERREUR notify_user_of_status_update: #{e.message}"
  end
end