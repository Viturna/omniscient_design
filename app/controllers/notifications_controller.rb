class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :create]
  layout 'admin', only: [:new, :create]

  def index
    @current_page = 'profil'
    current_user.notifications.update(status: :read)
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def new
    @current_page = "notifications"
    @users = User.all
    @notification = Notification.new 
  end

  def create
  message = params[:message]
  
  if params[:select_all] == "all" || params[:user_id] == "all"
    # Cas 1 : Envoi à tous
    User.find_each do |user|
      Notification.create(
        user: user,
        admin: current_user,
        message: message,
        status: :unread
      )
    end
    flash[:notice] = "Notification envoyée à tous les utilisateurs."
  
  elsif params[:user_ids].present?
    # Cas 2 : Envoi à un ou plusieurs utilisateurs sélectionnés
    target_user_ids = params[:user_ids].reject(&:blank?) # Nettoyer les IDs vides
    User.where(id: target_user_ids).find_each do |target_user|
      Notification.create(
        user: target_user,
        admin: current_user,
        message: message,
        status: :unread
      )
    end
    flash[:notice] = "Notification envoyée à #{target_user_ids.count} utilisateur(s) sélectionné(s)."
  
  else
    # Cas 3 : Rien n'est sélectionné
    flash[:alert] = "Veuillez sélectionner au moins un destinataire."
    redirect_to new_notification_path and return
  end
  
  redirect_to notifications_path # Rediriger vers l'index ou le dashboard après succès

rescue => e
  flash[:alert] = "Erreur lors de l'envoi : #{e.message}"
  redirect_to new_notification_path
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

  private 
  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end
