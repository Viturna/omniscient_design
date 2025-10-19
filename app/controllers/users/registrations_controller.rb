class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def new
    @etablissements = Etablissement.all
    super
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
        create_admin_notification_for_signup(resource)
        flash[:notice] = I18n.t('user.registration.confirmation_sent')
        return redirect_to confirmation_pending_path
      end
    end
  end

  def edit
    @current_page = 'profil'
    super
  end

  def update
    if resource.update_with_password(account_update_params)
       redirect_to edit_user_registration_path, notice: I18n.t('user.profile.updated')
    else
      clean_up_passwords(resource)
      set_minimum_password_length
      render :edit
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :pseudo, :rgpd_consent, :statut, :etablissement_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :pseudo, :statut, :etablissement_id])
  end

  private
  def create_admin_notification_for_signup(user)
    message = I18n.t('notifications.new_user_registered', name: user.full_name, default: "Nouvel utilisateur inscrit : #{user.full_name}")

    recipients = User.where("role = ? OR certified = ?", 'admin', true)

    recipients.each do |recipient|
      Notification.create!(
        user: recipient,
        notifiable: user,
        message: message
      )
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :pseudo, :rgpd_consent, :statut, :etablissement_id)
  end
end
