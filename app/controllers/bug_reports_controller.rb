class BugReportsController < ApplicationController
  before_action :authenticate_user!, only: [:new]
  before_action :authenticate_admin!, only: [:index, :show, :destroy]
  before_action :set_bug_report, only: [:show, :destroy, :update_status]

  def new
    @current_page = 'profil'
    @bug_report = BugReport.new
  end

  def create
    @current_page = 'profil'
    @bug_report = current_user.bug_reports.build(bug_report_params)
    if @bug_report.save
      BugReportMailer.new_bug_report(@bug_report).deliver_now
      redirect_to profil_path, notice: 'Votre signalement a été soumis avec succès.'
    else
      render :new
    end
  end

  def index
    @current_page = 'profil'
    @bug_reports_all= BugReport.all
    @bug_reports_todo = BugReport.where(status: 'À faire')
    @bug_reports_in_progress = BugReport.where(status: 'En cours')
    @bug_reports_resolved = BugReport.where(status: 'Corrigé')
  end

  def show
    @current_page = 'profil'
  end

  def destroy
    @bug_report.destroy
    redirect_to bug_reports_path, notice: 'Le rapport de bug a été supprimé avec succès.'
  end
  def update_status
    if @bug_report.update(status: params[:status])
      redirect_to bug_reports_path, notice: 'Le statut du rapport de bug a été mis à jour avec succès.'
    else
      redirect_to bug_reports_path, alert: 'Erreur lors de la mise à jour du statut.'
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
    redirect_to root_path, alert: "Vous n'êtes pas autorisé à accéder à cette page." unless current_user.admin?
  end
end
