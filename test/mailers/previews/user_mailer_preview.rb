# test/mailers/previews/devise_mailer_preview.rb
class DeviseMailerPreview < ActionMailer::Preview
  # ➤ URL : http://localhost:3000/rails/mailers/devise_mailer/reset_password_instructions
  def reset_password_instructions
    user = User.new(
      firstname: "Thomas",
      pseudo: "omniscient_thomas",
      email: "thomas@example.com"
    )

    token = "faketoken123"

    mail = Devise::Mailer.reset_password_instructions(user, token)

    # Injecte manuellement les variables attendues dans ta vue
    mail.instance_variable_set(:@user, user)
    mail.instance_variable_set(:@token, token)

    mail
  end
end
