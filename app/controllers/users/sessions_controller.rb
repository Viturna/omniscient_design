class Users::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :pseudo, :statut, :etablissement_id, :current_password])
  end
end
