class BugReportMailer < ApplicationMailer
  def new_bug_report(bug_report)
    @bug_report = bug_report
    mail(to: 'omniscientdesign.co@gmail.com', subject: 'Nouveau Rapport de bug')
  end
end
