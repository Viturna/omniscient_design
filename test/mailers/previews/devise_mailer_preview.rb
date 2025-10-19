# test/mailers/previews/devise_mailer_preview.rb
class DeviseMailerPreview < ActionMailer::Preview
  # preview URL:
  # http://localhost:3000/rails/mailers/devise_mailer/reset_password_instructions
  def reset_password_instructions
    user = User.new(
      firstname: "Prénom",
      pseudo: "pseudo_demo",
      email: "demo@example.com"
    )

    token = "faketoken123"

    # Essaie d'appeler le mailer configuré pour Devise.
    # On tente Devise.mailer (si tu as overridé le mailer dans config) puis Devise::Mailer.
    mailer = (defined?(Devise) && Devise.mailer) || Devise::Mailer
    mailer.reset_password_instructions(user, token)
  end
end
