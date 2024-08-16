class BugReportMailer < ApplicationMailer
  default from: 'omniscientdesign.co@gmail.com'

  def new_bug_report(bug_report)
    @bug_report = bug_report
    mail(subject: 'Nouveau Rapport de Bug - Omniscient Design')
  end
end
