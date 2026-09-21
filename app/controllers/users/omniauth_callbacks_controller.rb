class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: %i[google_oauth2 apple failure]

  def google_oauth2
    handle_auth 'Google'
  end

  def apple
    handle_auth 'Apple'
  end

  def failure
    if native_app? || request.env['omniauth.params']&.fetch('native_app', nil) == 'true'
      redirect_to "omniscient://auth_failure", allow_other_host: true
    else
      redirect_to root_path
    end
  end

  private

  def handle_auth(kind)
    auth = request.env['omniauth.auth']
    email = auth.info&.email

    # Recherche par provider/uid OU par email
    @user = User.find_by(provider: auth.provider, uid: auth.uid)
    if @user.nil? && email.present?
      @user = User.find_by(email: email)
      @user.update(provider: auth.provider, uid: auth.uid) if @user
    end

    if user_signed_in? && @user && @user != current_user
      flash[:alert] = "Ce compte #{kind} est déjà lié à un autre utilisateur."
      redirect_to(native_request? ? "omniscient://auth_failure" : edit_user_registration_path, allow_other_host: true)
    elsif @user&.persisted?
      unless @user.confirmed?
        @user.skip_confirmation!
        @user.save!
      end

      sign_in(:user, @user)
      if native_request?
        redirect_to "omniscient://auth_success", allow_other_host: true
      else
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
        redirect_to after_sign_in_path_for(@user)
      end
    else
      session['devise.omniauth_data'] = auth.except('extra')

      if kind == 'Apple' && session['devise.omniauth_data']['info']['email'].blank?
        session['devise.omniauth_data']['info']['email'] = auth['uid']
      end

      user = User.from_omniauth(auth) if User.respond_to?(:from_omniauth)
      if user&.persisted?
        sign_in(:user, user)
        if native_request?
          redirect_to "omniscient://auth_success", allow_other_host: true
        else
          redirect_to after_sign_in_path_for(user)
        end
      else
        redirect_to(native_request? ? "omniscient://auth_success" : new_user_registration_url, allow_other_host: true)
      end
    end
  end

  def native_request?
    native_app? || request.user_agent.to_s.include?('Turbo Native')
  end
end
