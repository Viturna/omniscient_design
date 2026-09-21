class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[google_oauth2 apple failure token_login]

  def google_oauth2
    handle_auth 'Google'
  end

  def apple
    handle_auth 'Apple'
  end

  def token_login
    token = params[:token]
    user = User.find_by(authentication_token: token) if token.present?

    if user.present?
      # Consomme le token (usage unique)
      user.update_column(:authentication_token, nil)
      sign_in(:user, user)
      redirect_to profil_path
    else
      redirect_to new_user_session_path, alert: "Session expirée. Veuillez réessayer."
    end
  end

  def failure
    render html: "<!DOCTYPE html><html><head><meta charset='utf-8'><script>window.location.href='omniscient://auth_failure';</script></head><body><p>Échec...</p></body></html>".html_safe
  end

  private

  def handle_auth(kind)
    auth = request.env['omniauth.auth']
    email = auth.info&.email

    @user = User.find_by(provider: auth.provider, uid: auth.uid)
    if @user.nil? && email.present?
      @user = User.find_by(email: email)
      @user&.update(provider: auth.provider, uid: auth.uid)
    end

    if user_signed_in? && @user && @user != current_user
      flash[:alert] = "Ce compte #{kind} est déjà lié à un autre utilisateur."
      render html: "<!DOCTYPE html><html><head><meta charset='utf-8'><script>window.location.href='omniscient://auth_failure';</script></head><body></body></html>".html_safe
    elsif @user&.persisted?
      unless @user.confirmed?
        @user.skip_confirmation!
        @user.save!
      end

      # Génère un jeton temporaire d'usage unique
      token = SecureRandom.hex(32)
      @user.update_column(:authentication_token, token)

      render html: "<!DOCTYPE html><html><head><meta charset='utf-8'><script>window.location.href='omniscient://auth_success?token=#{token}';</script></head><body><p>Connexion réussie...</p></body></html>".html_safe
    else
      session['devise.omniauth_data'] = auth.except('extra')

      if kind == 'Apple' && session['devise.omniauth_data']['info']['email'].blank?
        session['devise.omniauth_data']['info']['email'] = auth['uid']
      end

      user = User.from_omniauth(auth) if User.respond_to?(:from_omniauth)
      if user&.persisted?
        token = SecureRandom.hex(32)
        user.update_column(:authentication_token, token)
        render html: "<!DOCTYPE html><html><head><meta charset='utf-8'><script>window.location.href='omniscient://auth_success?token=#{token}';</script></head><body><p>Connexion réussie...</p></body></html>".html_safe
      else
        redirect_to new_user_registration_url
      end
    end
  end

  def native_request?
    native_app? || request.user_agent.to_s.include?('Turbo Native') || request.env['omniauth.params']&.fetch('native_app', nil) == 'true' || params[:native_app] == 'true'
  end
end
