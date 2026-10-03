class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: %i[token_login]
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[firstname lastname pseudo statut etablissement_id current_password])
  end
end

