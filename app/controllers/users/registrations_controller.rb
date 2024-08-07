class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def new
    @etablissements = Etablissement.all # or any other logic to fetch the establishments
    super
  end

  def create
    super do |user|
      if params[:user][:referral_code].present?
        referrer = User.find_by_referral_code(params[:user][:referral_code])
        if referrer
          Referral.create(referrer: referrer, referee: user, reward_claimed: false)
        end
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, :firstname, :lastname, :pseudo, :statut, :etablissement_id, :referral_code])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :firstname, :lastname, :pseudo, :statut, :etablissement_id, :current_password])
  end

  private
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :pseudo, :statut, :etablissement_id, :referral_code)
  end
end
