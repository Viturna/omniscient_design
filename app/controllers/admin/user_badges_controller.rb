module Admin
  class UserBadgesController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!
    layout 'admin'

    def new
      @users = User.order(:email)
      @badges = Badge.order(:name)
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
      redirect_to new_admin_user_badge_path, alert: "Utilisateur ou Badge introuvable."
    end

    private

    def authenticate_admin!
      redirect_to root_path, alert: "Accès interdit." unless current_user&.admin?
    end
  end
end