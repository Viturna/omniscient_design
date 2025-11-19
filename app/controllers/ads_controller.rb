class AdsController < ApplicationController
  # IMPORTANT : On autorise tout le monde (même non connecté) à cliquer sur la pub
  skip_before_action :authenticate_user!, only: [:click, :impression], raise: false
  skip_before_action :authenticate_admin!, only: [:click, :impression], raise: false

  def click
    @ad = Ad.find(params[:id])
    
    # Incrémente le compteur de clics
    @ad.increment!(:clicks_count)
    
    # Redirige vers le lien de la pub
    # allow_other_host: true est nécessaire car on sort de ton site
    redirect_to @ad.link, allow_other_host: true
  end

  def impression
    @ad = Ad.find(params[:id])
    
    # Incrémente le compteur de vues
    @ad.increment!(:impressions_count)
    
    # Renvoie une réponse vide pour ne pas charger de page
    head :ok
  end
end