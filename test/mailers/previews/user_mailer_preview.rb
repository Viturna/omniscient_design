# test/mailers/previews/user_mailer_preview.rb
class UserMailerPreview < ActionMailer::Preview
  # Prévisualisation de l’e-mail de réinitialisation du mot de passe
  def email_changed
    user = User.first || User.new(email: "exemple@demo.com")

    # S'assurer d'utiliser le mailer de Devise
    Devise.mailer.email_changed(user)
  end
end
