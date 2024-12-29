class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:add_elements, :profil, :parrainage, :parrainage_filleul]
  before_action :check_certified, only: [:validation]
  before_action :check_admin_role, only: [:suivi_references]
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
    @user = current_user
  end
  def validation
    @current_page = 'profil'
    @oeuvres = Oeuvre.all
    @designers = Designer.all
    @oeuvres_count = Oeuvre.where(validation: true).count
    @designers_count = Designer.where(validation: true).count
    @oeuvres_count_val_false = Oeuvre.where(validation: false).count
    @designers_count_val_false = Designer.where(validation: false).count
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
      @oeuvres = Oeuvre.order(:nom_oeuvre)
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
    @current_page = 'profil'
    @user = current_user
    @referred_users = @user.referred_users
    @referred_count = @referred_users.count
  end
  def parrainage_filleul
    @user = current_user

    if request.post?
      referral_code = params[:referral_code]

      if referral_code.blank?
        flash[:error] = "Veuillez fournir un code de parrainage."
        redirect_to parrainage_filleul_path and return
      end

      # Trouver le parrain correspondant au code
      referrer = User.find_by(referral_code: referral_code)

      if referrer
        if referrer == @user
          flash[:error] = "Vous ne pouvez pas être votre propre parrain."
        elsif Referral.exists?(referrer: referrer, referee: @user)
          flash[:notice] = "Vous êtes déjà lié à ce parrain."
        else
          begin
            # Créer la relation de parrainage
            Rails.logger.debug "user: #{@user.inspect}"
            Referral.create!(referrer: referrer, referee: @user)
            flash[:success] = "Vous avez été lié à votre parrain : #{referrer.pseudo}."
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.debug "user: #{@user.inspect}"
            Rails.logger.error "Erreur lors de la création de la relation de parrainage : #{e.message}"
            flash[:error] = "Une erreur est survenue. Veuillez réessayer."
          end
        end
      else
        flash[:error] = "Code de parrainage invalide."
      end

      redirect_to parrainage_path
    end
  end
  def suivi_references
    @current_page = 'profil'
    @suivis = Suivi.includes(:user).all
  end
  def changelog
    @current_page = 'profil'
  end

end
