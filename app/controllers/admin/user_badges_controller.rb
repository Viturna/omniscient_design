module Admin
  class UserBadgesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    layout 'admin'

    def new
      @users = User.order(:email)
      @badges = Badge.order(:name)

      @user_badges = UserBadge.includes(:user, :badge)

      if params[:search].present?
        query = "%#{params[:search].downcase}%"
        @user_badges = @user_badges.joins(:user, :badge)
                                   .where('LOWER(users.email) LIKE ? OR LOWER(users.pseudo) LIKE ? OR LOWER(badges.name) LIKE ?', query, query, query)
      end

      sort_column = params[:sort]
      sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'

      @user_badges = if sort_column == 'user'
                       @user_badges.references(:user).order("LOWER(COALESCE(users.pseudo, users.email)) #{sort_direction}")
                     elsif sort_column == 'badge'
                       @user_badges.references(:badge).order("LOWER(badges.name) #{sort_direction}")
                     elsif sort_column == 'date'
                       @user_badges.order(created_at: sort_direction.to_sym)
                     else
                       @user_badges.order(created_at: :desc)
                     end

      @user_badges = @user_badges.page(params[:page]).per(25)
    end

    def create
      user = User.find(params[:user_id])
      badge = Badge.find(params[:badge_id])

      if GamificationService.manual_assign(user, badge)
        redirect_to new_admin_user_badge_path, notice: "Le badge '#{badge.name}' a été attribué à #{user.pseudo}."
      else
        redirect_to new_admin_user_badge_path, alert: "Cet utilisateur possède déjà le badge '#{badge.name}'."
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_user_badge_path, alert: 'Utilisateur ou Badge introuvable.'
    end

    def destroy
      @user_badge = UserBadge.find(params[:id])
      user = @user_badge.user
      badge = @user_badge.badge

      if @user_badge.destroy
        redirect_to new_admin_user_badge_path,
                    notice: "Le badge '#{badge.name}' a été retiré avec succès à #{user.pseudo || user.email}."
      else
        redirect_to new_admin_user_badge_path, alert: 'Impossible de retirer le badge.'
      end
    end

    private

    def authenticate_admin!
      redirect_to root_path, alert: 'Accès interdit.' unless current_user&.admin?
    end
  end
end
