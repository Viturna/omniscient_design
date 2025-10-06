class UserMailerPreview < ActionMailer::Preview
  def email_changed
    user = User.first || User.new(email: "exemple@demo.com")
    Devise.mailer.email_changed(user)
  end
end
