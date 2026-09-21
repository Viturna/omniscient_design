class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[google_oauth2 apple failure]

  def google_oauth2
    handle_auth 'Google'
  end

  def apple
    handle_auth 'Apple'
  end

  def failure
    if native_request?
      redirect_to "omniscient://auth_failure", allow_other_host: true
    else
      redirect_to root_path, alert: "Échec de l'authentification."
    end
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
      redirect_to "omniscient://auth_failure", allow_other_host: true
    elsif @user&.persisted?
      unless @user.confirmed?
        @user.skip_confirmation!
        @user.save!
      end

      sign_in(:user, @user)
      # Redirige vers le schéma de l'application
      redirect_to "omniscient://auth_success", allow_other_host: true
    else
      session['devise.omniauth_data'] = auth.except('extra')

      if kind == 'Apple' && session['devise.omniauth_data']['info']['email'].blank?
        session['devise.omniauth_data']['info']['email'] = auth['uid']
      end

      user = User.from_omniauth(auth) if User.respond_to?(:from_omniauth)
      if user&.persisted?
        sign_in(:user, user)
        redirect_to "omniscient://auth_success", allow_other_host: true
      else
        redirect_to "omniscient://auth_failure", allow_other_host: true
      end
    end
  end

  def native_request?
    native_app? || request.user_agent.to_s.include?('Turbo Native') || request.env['omniauth.params']&.fetch('native_app', nil) == 'true' || params[:native_app] == 'true'
  end
end
