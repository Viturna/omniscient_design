class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def new
    @etablissements = Etablissement.all
    super do |resource|
      # Lecture de la clé générique unifiée
      if data = session['devise.omniauth_data']
        # On pré-remplit avec les infos disponibles
        resource.email = data['info']['email'] if resource.email.blank?
        resource.firstname = data['info']['first_name'] if resource.firstname.blank?
        resource.lastname = data['info']['last_name'] if resource.lastname.blank?
        
        # Très important : on fixe le provider et l'uid pour le formulaire caché
        resource.provider = data['provider']
        resource.uid = data['uid']

      end
    end
  end

  def create
    super do |user|
      if params[:user][:referral_code].present?
        referrer = User.find_by(referral_code: params[:user][:referral_code])
        if referrer
          Referral.create(referrer: referrer, referee: user, reward_claimed: false)
        end
      end

      if resource.persisted?
        # Nettoyage de la session après succès
        session.delete('devise.omniauth_data')

        create_admin_notification_for_signup(resource)
        # Si l'utilisateur est actif directement (pas de confirmation email requise pour OAuth parfois)
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          return respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          return respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        # En cas d'erreur (ex: validation manquante), on recharge les établissements pour réafficher le formulaire
        @etablissements = Etablissement.all
      end
    end
  end

  def edit
    @current_page = 'profil'
    super
  end

  def update
    if resource.provider.present? && account_update_params[:password].blank?
      params[:user].delete(:current_password)
      resource.update_without_password(account_update_params)
       redirect_to edit_user_registration_path, notice: I18n.t('user.profile.updated')
       return
    end

    if resource.update_with_password(account_update_params)
       redirect_to edit_user_registration_path, notice: I18n.t('user.profile.updated')
    else
      clean_up_passwords(resource)
      set_minimum_password_length
      render :edit
    end
  end

  def destroy
    delete_reason = params[:delete_reason]
    
    notify_admins_of_deletion(resource, delete_reason)

    super
  end
  

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :pseudo, :rgpd_consent, :statut, :etablissement_id, :how_did_you_hear, :study_level, :provider, :uid])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :pseudo, :statut, :etablissement_id, :how_did_you_hear, :study_level])
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path(verification_sent: true)
  end
  private

  def create_admin_notification_for_signup(user)
    message = I18n.t('notifications.new_user_registered', name: user.full_name, default: "Nouvel utilisateur inscrit : #{user.full_name}")
    recipients = User.where("role = ? OR certified = ?", 'admin', true)
    recipients.each do |recipient|
      Notification.create!(user: recipient, notifiable: user, message: message)
    end
  end

  def notify_admins_of_deletion(user, reason)
    reason_text = reason.present? ? reason : "Aucune raison spécifiée."
    
    message = "Compte supprimé : #{user.full_name} (ID: #{user.id}). Raison du départ : #{reason_text}"

    recipients = User.where("role = ? OR certified = ?", 'admin', true)
    
    recipients.each do |recipient|
      Notification.create(user: recipient, notifiable: recipient, message: message)
    end
  rescue => e
    Rails.logger.error "Erreur lors de la notification de suppression de compte : #{e.message}"
  end
end