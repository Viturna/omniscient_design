class AdsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[click impression new create success cancel], raise: false
  skip_before_action :authenticate_admin!, only: %i[click impression new create success cancel], raise: false

  def new
    @ad = Ad.new
  end

  def create
    pack_key = params[:ad][:pack]
    pack = Ad::PACKS[pack_key]

    unless pack
      redirect_to new_ad_path, alert: "Veuillez sélectionner un pack valide."
      return
    end

    @ad = Ad.new(ad_params)
    @ad.weight = pack[:weight]
    @ad.duration_days = pack[:days]
    @ad.price_paid = pack[:price_cents]
    @ad.status = 'pending'
    @ad.active = false

    if @ad.save
      redirect_to success_ad_path(@ad), notice: "Votre publicité a bien été créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def success
    @ad = Ad.find(params[:id])
    # Affichage du succès de paiement
  end

  def cancel
    @ad = Ad.find(params[:id])
    # L'utilisateur a annulé
  end

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

  private

  def ad_params
    params.require(:ad).permit(:title, :link, :description, :email, :image)
  end
end
