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
    @user = User.find_by(provider: auth.provider, uid: auth.uid)

    if user_signed_in?
      # Cas 1 : Liaison de compte
      if @user && @user != current_user
        flash[:alert] = "Ce compte #{kind} est déjà lié à un autre utilisateur."
        redirect_to edit_user_registration_path
      else
        begin
          current_user.update!(provider: auth.provider, uid: auth.uid)
          flash[:notice] = "Ton compte a été lié à #{kind} avec succès."
        rescue ActiveRecord::RecordInvalid => e
          flash[:alert] = "Erreur lors de la liaison : #{e.record.errors.full_messages.join(', ')}"
        end
        redirect_to edit_user_registration_path
      end
    elsif @user&.persisted?
      # Cas 2 : Utilisateur existant -> Connexion
      unless @user.confirmed?
        @user.skip_confirmation!
        @user.save!
      end

      sign_in(:user, @user)

      # 📱 Si c'est l'app iOS native (ASWebAuthenticationSession) : on redirige vers omniscient:// pour fermer la popup
      if native_app? || request.user_agent.to_s.include?('Turbo Native') || request.user_agent.to_s.include?('iPhone')
        redirect_to "omniscient://auth_success", allow_other_host: true
      else
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
        redirect_to after_sign_in_path_for(@user)
      end

    else
      # Cas 3 : Nouvel utilisateur
      session['devise.omniauth_data'] = auth.except('extra')

      if kind == 'Apple' && session['devise.omniauth_data']['info']['email'].blank?
        session['devise.omniauth_data']['info']['email'] = auth['uid']
      end

      if native_app? || request.user_agent.to_s.include?('Turbo Native') || session[:is_native_app]
        # Création automatique ou redirection vers inscription
        user = User.from_omniauth(auth) if User.respond_to?(:from_omniauth)
        if user&.persisted?
          sign_in(:user, user)
          redirect_to "omniscient://auth_success", allow_other_host: true
        else
          redirect_to new_user_registration_url
        end
      else
        redirect_to new_user_registration_url
      end
    end
  end
end
