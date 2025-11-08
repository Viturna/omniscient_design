class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:google_oauth2, :apple]

  def google_oauth2
    handle_auth "Google"
  end

  def apple
    handle_auth "Apple"
  end

  def failure
    redirect_to root_path
  end

  private

  def handle_auth(kind)
    auth = request.env['omniauth.auth']
    @user = User.find_by(provider: auth.provider, uid: auth.uid)

    if user_signed_in?
      # Cas : Utilisateur déjà connecté qui veut lier son compte
      if @user && @user != current_user
        # Ce compte Google/Apple est déjà utilisé par QUELQU'UN D'AUTRE
        flash[:alert] = "Ce compte #{kind} est déjà lié à un autre utilisateur."
        redirect_to edit_user_registration_path
      else
        # On lie le compte actuel au provider
        # Note : Cela écrasera un lien précédent si votre modèle User n'a qu'une seule colonne provider/uid.
        current_user.update(provider: auth.provider, uid: auth.uid)
        flash[:notice] = "Votre compte a été lié à #{kind} avec succès."
        redirect_to edit_user_registration_path
      end
    else
      # Cas : Connexion ou Inscription (votre code existant)
      if @user&.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.omniauth_data'] = auth.except('extra')
        if kind == "Apple" && session['devise.omniauth_data']['info']['email'].blank?
           session['devise.omniauth_data']['info']['email'] = auth['uid']
        end
        redirect_to new_user_registration_url
      end
    end
  end
end