class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :create]
  layout 'admin', only: [:new, :create]

  def index
    @current_page = 'profil'
    current_user.notifications.unread.update_all(status: :read) # Optimisation de l'update
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def new
    @current_page = "notifications"
    @users = User.all
    @notification = Notification.new 
  end

  def create
    title = params[:title] 
    message = params[:message]
    link = params[:link]
    
    ActiveRecord::Base.transaction do
      if params[:select_all] == "all" || params[:user_id] == "all"
        User.find_each do |user|
          Notification.create!(
            user: user,
            admin: current_user,
            title: title,
            message: message,
            link: link,
            status: :unread,
            notifiable: user 
          )
        end
        flash[:notice] = "Notification envoyée à tous les utilisateurs."
      
      elsif params[:user_ids].present?
        target_user_ids = params[:user_ids].reject(&:blank?)
        
        User.where(id: target_user_ids).find_each do |target_user|
          Notification.create!(
            user: target_user,
            admin: current_user,
            title: title,
            message: message,
            link: link,
            status: :unread,
            notifiable: target_user
          )
        end
        flash[:notice] = "Notification envoyée à #{target_user_ids.count} utilisateur(s) sélectionné(s)."
      
      else
        flash[:alert] = "Veuillez sélectionner au moins un destinataire."
        redirect_to new_notification_path and return
      end
    end
    
    redirect_to notifications_path

  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Erreur de validation : #{e.message}"
    redirect_to new_notification_path
  rescue => e
    flash[:alert] = "Erreur lors de l'envoi : #{e.message}"
    redirect_to new_notification_path
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.update(status: :read) if @notification
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_to notifications_path, notice: "Notification supprimée."
  end

  private 

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end