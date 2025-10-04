# test/mailers/previews/user_mailer_preview.rb
class UserMailerPreview < ActionMailer::Preview
  # Prévisualisation de l’e-mail de réinitialisation du mot de passe
  def reset_password_instructions
    user = User.first || User.new(email: "exemple@demo.com")
    token = "faux_token_123"

    # S'assurer d'utiliser le mailer de Devise
    Devise.mailer.reset_password_instructions(user, token)
  end
end
