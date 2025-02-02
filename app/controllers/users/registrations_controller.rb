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
        flash[:notice] = "Un email de confirmation vous a été envoyé. Veuillez vérifier votre boîte de réception."
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
      redirect_to edit_user_registration_path, notice: "Votre profil a été mis à jour avec succès."
    else
      clean_up_passwords(resource)
      set_minimum_password_length
      render :edit
    end
  end

  def update_resource(resource, params)
    if params[:remove_profile_image] == '1'
      resource.profile_image.purge
    elsif params[:keep_profile_image] == 'true'
      params.delete(:profile_image)
    end
    resource.update(params.except(:current_password))
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :pseudo, :profile_image, :rgpd_consent, :statut, :etablissement_id, :referral_code])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :pseudo, :profile_image, :remove_profile_image, :statut, :etablissement_id])
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :pseudo, :profile_image, :rgpd_consent, :statut, :etablissement_id, :referral_code)
  end
end
