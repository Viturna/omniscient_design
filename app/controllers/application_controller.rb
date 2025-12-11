class ApplicationController < ActionController::Base
  before_action :set_unread_notifications_count
  before_action :check_if_banned
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :track_visit, if: :user_signed_in?

  def set_theme
    theme = params[:theme]
    cookies[:theme] = theme
    redirect_back(fallback_location: root_path)
  end
  
  helper_method :native_app?

  def native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end
  private

  def set_unread_notifications_count
    @unread_notifications_count = current_user.notifications.unread.count if user_signed_in?
  end
  def set_active_storage_url_options
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end

  def check_admin_role
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: I18n.t('user.access.denied_admin')
    end
  end
  def check_certified
    unless user_signed_in? && (current_user.certified? || current_user&.admin?)
      redirect_to root_path, alert: I18n.t('user.access.denied_certified')
    end
  end
  def check_if_banned
    if user_signed_in? && current_user.banned?
      sign_out_and_redirect(current_user)
      flash[:alert] = I18n.t('user.access.banned')
    end
  end

  def track_visit
    timeout = 30.minutes
    last_activity = session[:last_activity_at]

    if last_activity.nil? || last_activity.to_time < timeout.ago
      DailyVisit.create(user: current_user, visited_on: Date.current)
    end

    session[:last_activity_at] = Time.current
  end

   def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:referral_code])
  end
end
