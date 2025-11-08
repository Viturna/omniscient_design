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
    # On cherche si ce compte Google/Apple est déjà enregistré dans la base
    @user = User.find_by(provider: auth.provider, uid: auth.uid)

    if user_signed_in?
      # Cas : L'utilisateur est connecté et veut lier ce compte externe à son profil actuel
      if @user && @user != current_user
        # Erreur : Ce compte Google/Apple est déjà lié à un AUTRE utilisateur
        flash[:alert] = "Ce compte #{kind} est déjà lié à un autre utilisateur."
        redirect_to edit_user_registration_path
      else
        # On tente de lier le compte. On utilise update! dans un bloc begin/rescue
        # pour attraper les éventuelles erreurs de validation qui seraient silencieuses sinon.
        begin
          current_user.update!(provider: auth.provider, uid: auth.uid)
          flash[:notice] = "Votre compte a été lié à #{kind} avec succès."
        rescue ActiveRecord::RecordInvalid => e
          # Affiche la raison exacte de l'échec (ex: email manquant, format invalide, etc.)
          flash[:alert] = "Erreur lors de la liaison : #{e.record.errors.full_messages.join(', ')}"
        end
        redirect_to edit_user_registration_path
      end
    else
      # Cas : L'utilisateur n'est PAS connecté (Connexion ou Inscription classique)
      if @user&.persisted?
        # Le compte existe, on le connecte
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
        sign_in_and_redirect @user, event: :authentication
      else
        # Nouvel utilisateur, on stocke les infos pour le formulaire d'inscription
        session['devise.omniauth_data'] = auth.except('extra')
        # Fix spécifique pour Apple qui parfois ne renvoie pas l'email dans 'info'
        if kind == "Apple" && session['devise.omniauth_data']['info']['email'].blank?
           session['devise.omniauth_data']['info']['email'] = auth['uid']
        end
        redirect_to new_user_registration_url
      end
    end
  end
end