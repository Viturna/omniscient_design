class Users::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters, if: :devise_controller?
  def create
    self.resource = warden.authenticate!(auth_options)

    if !resource.confirmed?
      resend_link = view_context.link_to('Renvoyer l\'email de confirmation', new_user_confirmation_path)
      set_flash_message! :alert, :unconfirmed, resend_link: resend_link
      respond_with_navigational(resource) { render :new }
    else
      super
    end
  end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :pseudo, :statut, :etablissement_id, :profile_image, :current_password])
  end
end
