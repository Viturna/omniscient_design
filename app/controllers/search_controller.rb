class SearchController < ApplicationController
  def autocomplete
    query = params[:query].to_s.strip

    # Recherche dans Oeuvre, Designer et Domaine avec Searchkick
    @oeuvre_suggestions = Oeuvre.search(query, fields: [:nom_oeuvre], match: :word_start, where: { validation: true })
    @designer_suggestions = Designer.search(query, fields: [:nom, :prenom], match: :word_start, where: { validation: true })
    @domaine_suggestions = Domaine.search(query, fields: [:domaine], match: :word_start)

    # Mapper les résultats
    oeuvre_results = @oeuvre_suggestions.results.map { |oeuvre| 
      { name: oeuvre.nom_oeuvre,
        url: oeuvre_path(oeuvre),
        img: oeuvre.image.present? ? helpers.asset_path(oeuvre.image) : nil
      }
    }

    designer_results = @designer_suggestions.results.map { |designer| 
      { name: "#{designer.prenom} #{designer.nom}",
       url: designer_path(designer),
       img: designer.image.present? ? helpers.asset_path(designer.image) : nil }
    }

    domaine_results = @domaine_suggestions.results.map do |domaine|
      { 
        name: domaine.domaine, 
        url: search_path(:domaine => domaine.id) , 
        svg: domaine.svg.present? ? helpers.asset_path("domaines/#{domaine.svg}") : nil 
      }
    end

    # Organiser les résultats sous trois sections séparées
    suggestions = {
      designers: {
        title: "Designers",
        class: "section-title",
        results: designer_results
        
      },
      oeuvres: {
        title: "Références",
        class: "section-title",
        results: oeuvre_results
      },
      domaines: {
        title: "Domaines",
        class: "section-title",
        results: domaine_results
      }
    }

    render json: suggestions
  end

  def search
    @current_page = 'recherche'
    @countries = Country.where(id: DesignerCountry.select(:country_id).distinct)
    @notions = Notion.all
    query = params[:query].to_s.strip
  
    if query.present?
      # Recherche dans Oeuvre et Designer avec Searchkick
      @oeuvre_suggestions = Oeuvre.search(query, fields: [:nom_oeuvre], match: :word_start)
      @designer_suggestions = Designer.search(query, fields: [:prenom, :nom], match: :word_start)
    end
  
    # Récupération des œuvres et designers validés pour affichage
    @oeuvres = Oeuvre.where(validation: true).order(:nom_oeuvre).page(params[:page])
    @designers = Designer.where(validation: true).order(:nom).page(params[:page])
    # Application des filtres
    if params[:domaine].present?
      filtered_domains = Array(params[:domaine]).reject(&:blank?)  # Convertir en tableau et filtrer
      if filtered_domains.any?
        @oeuvres = @oeuvres.where(domaine_id: filtered_domains)
        @designers = @designers.joins(:domaines).where(domaines: { id: filtered_domains })
      end
    end    

    if params[:country].present?
      countries = Array(params[:country]).reject(&:blank?) 
      if countries.any?
        @designers = @designers.joins(:countries).where(countries: { id: countries })
      end
    end
    
    if params[:notion].present? && params[:notion].reject(&:blank?).any?
      @oeuvres = @oeuvres.joins(:notions).where(notions: { id: params[:notion] })
    end
  
    if params[:start_year].present? && params[:end_year].present?
      start_year = params[:start_year].to_i
      end_year = params[:end_year].to_i
    
      if start_year > 0 && end_year > 0 && start_year <= end_year
        @designers = @designers.where("date_naissance BETWEEN ? AND ?", start_year, end_year)
        @oeuvres = @oeuvres.where("date_oeuvre BETWEEN ? AND ?", start_year, end_year)
        @timeline_years = (start_year..end_year).to_a
      else
        start_year =  1880
        end_year = Time.now.year
        @timeline_years = (start_year..end_year).to_a
      end
      else
        start_year =  1880
        end_year = Time.now.year
        @timeline_years = (start_year..end_year).to_a
    end
  
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end 
end
