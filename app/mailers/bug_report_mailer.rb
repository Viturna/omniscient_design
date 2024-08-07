class BugReportMailer < ApplicationMailer
  default to: -> { User.where(role: 'admin').pluck(:email) }

  def new_bug_report(bug_report)
    @bug_report = bug_report
    mail(subject: 'Nouveau Rapport de Bug')
  end
end
