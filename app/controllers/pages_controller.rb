class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:add_elements, :profil, :parrainage]
  before_action :check_admin_role, only: [:validation]
  def presentation
  end

  def add_elements
    @current_page = 'add_elements'
  end

  def users
  end

  def admin
  end

  def profil
    @current_page = 'profil'
  end
  def validation
    @current_page = 'profil'
    @oeuvres = Oeuvre.all
    @designers = Designer.all
    @oeuvres_count = Oeuvre.where(validation: true).count
    @designers_count = Designer.where(validation: true).count
  end
  def mentionslegales
  end
  def politiquedeconfidentialite
  end
  def cookies
  end
  def search_category
    @current_page = 'recherche'
    if params[:id].present?
      @oeuvre = Oeuvre.find(params[:id])
    else
      @oeuvre = Oeuvre.all # Ou toute autre logique pour récupérer toutes les œuvres
    end
  end
  def search_frise
    @current_page = 'recherche'
    @oeuvres = Oeuvre.where(validation: true).shuffle
    @designers = Designer.where(validation: true).shuffle

    # Date oeuvres
    @start_year_oeuvre = params[:start_year_oeuvre].to_i.positive? ? params[:start_year_oeuvre].to_i : 1880
    @end_year_oeuvre = params[:end_year_oeuvre].to_i.positive? ? params[:end_year_oeuvre].to_i : Date.current.year
    # Date designers
    @start_year_designer = params[:start_year_designer].to_i.positive? ? params[:start_year_designer].to_i : 1830
    @end_year_designer = params[:end_year_designer].to_i.positive? ? params[:end_year_designer].to_i : Date.current.year

    # Par défaut, tous les domaines sont affichés
    @domaine_id = params[:domaine_id].present? ? params[:domaine_id].to_i : nil
    # Par défaut, tous les pays sont affichés
    @country_id = params[:country_id].present? ? params[:country_id].to_i : nil

    # Récupérer toutes les années distinctes avec des œuvres
    @timeline_years = (@start_year_oeuvre..@end_year_oeuvre).to_a
    # Récupérer toutes les années distinctes avec des designers
    @timeline_years_2 = (@start_year_designer..@end_year_designer).to_a

    # Filtrer les œuvres par année, domaine et pays si nécessaire
    @oeuvres_filtered = @oeuvres.select do |oeuvre|
      oeuvre.date_oeuvre.to_i.between?(@start_year_oeuvre, @end_year_oeuvre) &&
        (oeuvre.domaine_id == @domaine_id || @domaine_id.nil?)
    end

    # Filtrer les designers par année et pays si nécessaire
    @designers_filtered = @designers.select do |designer|
      designer.date_naissance.to_i.between?(@start_year_designer, @end_year_designer) &&
        (designer.country_id == @country_id || @country_id.nil?)
    end

    # Récupérer tous les pays pour les options de sélection
    @countries = Country.order(:country).to_a.unshift(Country.new(id: nil, country: "Tous les pays"))
    @domaines = Domaine.all.to_a.unshift(Domaine.new(id: nil, domaine: "Tous les domaines"))
  end
  def parrainage
    @user = current_user
  end
  def suivi_references
    @current_page = 'profil'
    @suivis = Suivi.includes(:user).all
  end
  def changelog
    @current_page = 'profil'
  end

end
