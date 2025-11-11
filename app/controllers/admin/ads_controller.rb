class Admin::AdsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin! 
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  def index
    @current_page = 'ads'
    @ads = Ad.all.order(created_at: :desc)
  end

  def show
  end

  def new
     @current_page = 'ads'
    @ad = Ad.new
  end

  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      redirect_to admin_ads_path, notice: "Publicité créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ad.update(ad_params)
      redirect_to admin_ads_path, notice: "Publicité mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ad.destroy
    redirect_to admin_ads_path, notice: "Publicité supprimée."
  end

  private

  def set_ad
    @ad = Ad.find(params[:id])
  end

  def ad_params
    params.require(:ad).permit(:title, :description, :link, :active, :start_date, :end_date, :image, :image_mobile)
  end

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end