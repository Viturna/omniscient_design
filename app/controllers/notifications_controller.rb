class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :create]
  layout 'admin', only: [:new, :create]

  def index
    @current_page = 'profil'
    current_user.notifications.unread.update_all(status: :read)
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def new
    @current_page = "notifications"
    @users = User.all
    @notification = Notification.new 
  end

  def create
    # 1. On récupère les données proprement via strong params
    # Cela gère le cas où le formulaire envoie "notification[title]" ou juste "title"
    vals = params[:notification] || params 
    
    title = vals[:title]
    message = vals[:message]
    link = vals[:link]

    # Debug: Affiche ça dans votre terminal serveur pour vérifier
    Rails.logger.info "📢 Tentative envoi Notif - Titre: #{title} | Message: #{message}"

    if title.blank? || message.blank?
      flash[:alert] = "Le titre et le message sont obligatoires."
      redirect_to new_notification_path and return
    end
    
    # Compteur pour le feedback
    count = 0

    # 2. Définition des cibles
    targets = if params[:select_all] == "all" || params[:user_id] == "all"
                User.all
              elsif params[:user_ids].present?
                User.where(id: params[:user_ids].reject(&:blank?))
              else
                []
              end

    if targets.empty?
      flash[:alert] = "Veuillez sélectionner au moins un destinataire."
      redirect_to new_notification_path and return
    end

    # 3. Création boucle (Sans transaction globale pour éviter les timeouts sur le push synchrone)
    targets.find_each do |target_user|
      begin
        Notification.create!(
          user: target_user,
          admin: current_user,
          title: title,
          message: message,
          link: link,
          status: :unread,
          notifiable: nil # On garde nil comme dans votre test console qui marchait
        )
        count += 1
      rescue => e
        Rails.logger.error "❌ Erreur envoi notif user #{target_user.id}: #{e.message}"
      end
    end
    
    flash[:notice] = "Notification envoyée avec succès à #{count} utilisateur(s)."
    redirect_to notifications_path
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