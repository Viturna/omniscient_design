class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_page = 'profil'
    current_user.notifications.update(status: :read)
    @notifications = current_user.notifications.order(created_at: :desc)
  end


  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.update(status: :read) if @notification #
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted successfully."
  end
end
