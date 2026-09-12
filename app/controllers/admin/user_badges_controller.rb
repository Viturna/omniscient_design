module Admin
  class UserBadgesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    layout 'admin'

    def new
      @users = User.order(:email)
      @badges = Badge.order(:name)

      @user_badges = UserBadge.includes(:user, :badge)

      query_param = params[:query].presence || params[:search].presence
      if query_param.present?
        query = "%#{query_param.downcase}%"
        @user_badges = @user_badges.joins(:user, :badge)
                                   .where('LOWER(users.email) LIKE :q OR LOWER(users.pseudo) LIKE :q OR LOWER(badges.name) LIKE :q', q: query)
      end

      if params[:badge_id].present?
        @user_badges = @user_badges.where(badge_id: params[:badge_id])
      end

      if params[:category].present?
        @user_badges = @user_badges.joins(:badge).where(badges: { category: params[:category] })
      end

      sort_column = params[:sort]
      sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'

      @user_badges = if sort_column == 'user_asc'
                       @user_badges.joins(:user).order("LOWER(COALESCE(users.pseudo, users.email)) ASC")
                     elsif sort_column == 'user_desc'
                       @user_badges.joins(:user).order("LOWER(COALESCE(users.pseudo, users.email)) DESC")
                     elsif sort_column == 'badge_asc'
                       @user_badges.joins(:badge).order("LOWER(badges.name) ASC")
                     elsif sort_column == 'badge_desc'
                       @user_badges.joins(:badge).order("LOWER(badges.name) DESC")
                     elsif sort_column == 'date_asc'
                       @user_badges.order(created_at: :asc)
                     elsif sort_column == 'date_desc'
                       @user_badges.order(created_at: :desc)
                     elsif sort_column == 'user'
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
