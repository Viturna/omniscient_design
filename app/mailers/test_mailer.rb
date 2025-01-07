class TestMailer < ApplicationMailer
  def sample_email(recipient)
    @recipient = recipient
    mail(to: @recipient, subject: "Hello from Omniscient Design!")
  end
end
