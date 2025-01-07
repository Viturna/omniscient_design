class BugReportMailer < ApplicationMailer
  def new_bug_report(bug_report)
    @bug_report = bug_report
    mail(to: 'contact@omniscientdesign.fr', subject: 'Nouveau Rapport de bug')
  end
end
