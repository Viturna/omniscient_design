class ApplicationController < ActionController::Base
  before_action :set_unread_notifications_count
  before_action :check_if_banned

  private

  def set_unread_notifications_count
    @unread_notifications_count = current_user.notifications.unread.count if user_signed_in?
  end
  def set_active_storage_url_options
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end

  def check_admin_role
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "Vous n'avez pas la permission d'accéder à cette page."
    end
  end
  def check_if_banned
    if user_signed_in? && current_user.banned?
      sign_out_and_redirect(current_user)
      flash[:alert] = 'Votre compte a été banni.'
    end
  end
end
