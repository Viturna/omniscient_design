class BadgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_page = 'profil'

    @gamification_service = GamificationService.new(current_user)
    @gamification_service.check_seniority
    @gamification_service.check_artchiveur

    @badges = Badge.all

    @my_badge_ids = current_user.badge_ids
    session[:last_seen_badges_count] = @my_badge_ids.count

    @special_badges = @badges.select { |b| b.special? }
    @level_badges = @badges.reject { |b| b.special? }.group_by(&:category)
  end

  def rate_app
    GamificationService.new(current_user).check_omniscient_supporter
    head :ok
  end

  def community
    GamificationService.new(current_user).check_community_member
    head :ok
  end
end
