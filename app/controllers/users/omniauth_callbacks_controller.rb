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
    user_id = Rails.application.message_verifier(:mobile_auth).verify(token, purpose: :mobile_login) rescue nil

    if user_id.present? && (user = User.find_by(id: user_id))
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
      redirect_to(native_app_request? ? "omniscient://auth_failure" : edit_user_registration_path, allow_other_host: true)
    elsif @user&.persisted?
      unless @user.confirmed?
        @user.skip_confirmation!
        @user.save!
      end

      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.omniauth_data'] = auth.except('extra')

      if kind == 'Apple' && session['devise.omniauth_data']['info']['email'].blank?
        session['devise.omniauth_data']['info']['email'] = auth['uid']
      end

      user = User.from_omniauth(auth) if User.respond_to?(:from_omniauth)
      if user&.persisted?
        sign_in_and_redirect user, event: :authentication
      else
        redirect_to new_user_registration_url
      end
    end
  end

  def native_app_request?
    native_app? ||
      request.user_agent.to_s.include?('Turbo Native') ||
      request.env['omniauth.params']&.fetch('native_app', nil) == 'true' ||
      params[:native_app] == 'true' ||
      session[:is_native_app] == true
  end
end
