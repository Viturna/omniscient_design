class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :create]
  layout 'admin', only: [:new, :create]

  def index
    @current_page = 'profil'
    current_user.notifications.unread.update_all(status: :read)
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(25)
  end

  def new
    @current_page = "notifications"
    @users = User.all
    @notification = Notification.new 

    @campaigns = Notification.where("admin_id IS NOT NULL OR title = ?", "La réf du jour")
                             .group(:title, :message, :link, :admin_id)
                             .select("MIN(id) as id, title, message, link, admin_id, COUNT(*) as total_sent, COUNT(CASE WHEN status = 1 THEN 1 END) as total_read, COUNT(clicked_at) as total_clicks, MIN(created_at) as sent_at")
                             .order("sent_at DESC")
                             .page(params[:page]).per(10)
  end

  def create
    # 1. On récupère les données proprement via strong params
    # Cela gère le cas où le formulaire envoie "notification[title]" ou juste "title"
    vals = params[:notification] || params 
    
    title = vals[:title]
    message = vals[:message]
    link = vals[:link]

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
      flash[:alert] = "Sélectionne au moins un destinataire."
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
          notifiable: nil
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

  def click
    @notification = current_user.notifications.find_by(id: params[:id])
    if @notification.nil?
      redirect_to root_path, alert: "Notification introuvable."
      return
    end

    @notification.update(status: :read, clicked_at: Time.current) if @notification.clicked_at.nil?

    target_path = if @notification.link.present?
                    @notification.link
                  elsif @notification.notifiable_type&.safe_constantize && @notification.notifiable.present?
                    polymorphic_path(@notification.notifiable) rescue nil
                  end

    target_path ||= root_path
    redirect_to target_path
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