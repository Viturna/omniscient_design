class AdsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:click, :impression], raise: false
  skip_before_action :authenticate_admin!, only: [:click, :impression], raise: false

  def click
    @ad = Ad.find(params[:id])
    
    @ad.increment!(:clicks_count)
    
    redirect_to @ad.link, allow_other_host: true
  end

  def impression
    @ad = Ad.find(params[:id])
    
    @ad.increment!(:impressions_count)
    
    head :ok
  end
end