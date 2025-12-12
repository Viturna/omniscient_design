class BadgesController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_page = 'profil'
    
    @badges = Badge.all
    
    @my_badge_ids = current_user.badge_ids

    @special_badges = @badges.select { |b| b.special? }
    @level_badges = @badges.reject { |b| b.special? }.group_by(&:category)
  end
end