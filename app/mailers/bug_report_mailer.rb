class BugReportMailer < ApplicationMailer
  default from: 'omniscientdesign.co@gmail.com'

  def notification_email
    @bug_report = params[:bug_report]
    mail(to: 'omniscientdesign.co@gmail.com', subject: 'New Bug Report')
  end
end
