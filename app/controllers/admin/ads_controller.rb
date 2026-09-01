class Admin::AdsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_ad, only: %i[show edit update destroy approve reject]

  def index
    @current_page = 'ads'
    @ads = Ad.all.order(created_at: :desc)
  end

  def show; end

  def new
    @current_page = 'ads'
    @ad = Ad.new
  end

  def create
    @ad = Ad.new(ad_params)
    if @ad.save
      redirect_to admin_ads_path, notice: 'Publicité créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ad.update(ad_params)
      redirect_to admin_ads_path, notice: 'Publicité mise à jour.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ad.destroy
    redirect_to admin_ads_path, notice: 'Publicité supprimée.'
  end

  def approve
    start_date = @ad.start_date || Date.current
    end_date = if @ad.duration_days.present?
                 start_date + @ad.duration_days.days
               else
                 @ad.end_date
               end

    @ad.update(
      status: 'approved',
      active: true,
      start_date: start_date,
      end_date: end_date
    )
    redirect_to admin_ads_path, notice: 'Publicité validée ! Elle est désormais active.'
  end

  def reject
    @ad.update(status: 'rejected', active: false)
    redirect_to admin_ads_path, notice: 'Publicité refusée.'
  end

  private

  def set_ad
    @ad = Ad.find(params[:id])
  end

  def ad_params
    params.require(:ad).permit(:title, :description, :link, :weight, :logged_out_only, :active, :start_date, :end_date, :image, :image_mobile)
  end

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: 'Accès interdit.'
  end
end
