class SearchController < ApplicationController
    include ApplicationHelper
   def autocomplete
    query = params[:query].to_s.strip

    if query.length < 2
      return render json: { error: "Query too short" }, status: :bad_request
    end

    domaines = Domaine.where("domaine ILIKE ?", "%#{query}%").limit(5)
    designers = Designer.where(validation: true).where(
      "prenom ILIKE :q OR nom ILIKE :q OR (prenom || ' ' || nom) ILIKE :q OR (nom || ' ' || prenom) ILIKE :q",
      q: "%#{query}%"
    ).limit(5)

    oeuvres = Oeuvre.where(validation: true).where("nom_oeuvre ILIKE ?", "%#{query}%").limit(5)

    render json: {
      domaines: {
        title: "Domaines",
        class: "section-title",
        results: domaines.map do |d|
          {
            name: d.domaine,
              url: search_path(tab: 'frise', domaine: [d.id]),
            svg: "/assets/domaines/#{d.svg}"
          }
        end
      },
      designers: {
        title: "Designers",
        class: "section-title",
        results: designers.map do |d|
          {
            name: d.nom_designer,
            url: designer_path(d),
            img: "/assets/designers/thumbs/#{remove_accents_and_special_chars(d.nom_designer)}.webp"
          }
        end
      },
      oeuvres: {
        title: "Références",
        class: "section-title",
        results: oeuvres.map do |o|
          {
            name: o.nom_oeuvre,
            url: oeuvre_path(o),
            img: "/assets/oeuvres/thumbs/#{remove_accents_and_special_chars(o.nom_oeuvre)}.webp"
          }
        end
      }
    }
    rescue => e
      Rails.logger.error "[Autocomplete] Erreur: #{e.message}"
      render json: { error: "Erreur serveur" }, status: 500
  end


  def search
    @current_page = 'recherche'
    @countries = Country.where(id: DesignerCountry.select(:country_id).distinct)
    @notions = Notion.all
    query = params[:query].to_s.strip
  
   if query.present?
    # Recherche sur designers et oeuvres, avec limite 1 chacun, ordre par similarité (simple LIKE ici)
    designer = Designer.where(validation: true)
      .where("prenom ILIKE :q OR nom ILIKE :q OR (prenom || ' ' || nom) ILIKE :q OR (nom || ' ' || prenom) ILIKE :q", q: "%#{query}%")
      .order(
        Arel.sql("CASE WHEN nom ILIKE #{ActiveRecord::Base.connection.quote(query)} THEN 0 ELSE 1 END, nom ASC")
      )
      .first

    oeuvre = Oeuvre.where(validation: true)
      .where("nom_oeuvre ILIKE ?", "%#{query}%")
      .order(
        Arel.sql("CASE WHEN nom_oeuvre ILIKE #{ActiveRecord::Base.connection.quote(query)} THEN 0 ELSE 1 END, nom_oeuvre ASC")
      )
      .first

    # Si on a un designer dont le nom/prénom correspond quasi-exactement, on redirige vers lui
    if designer && (oeuvre.nil? || query.length <= designer.nom.length)
      redirect_to designer_path(designer) and return
    end

    # Sinon si on a une oeuvre, on redirige vers elle
    if oeuvre
      redirect_to oeuvre_path(oeuvre) and return
    end
  end
    # Récupération des œuvres et designers validés pour affichage
    @oeuvres = Oeuvre.where(validation: true).order(:nom_oeuvre).page(params[:page])
    @designers = Designer.where(validation: true).order(:nom).page(params[:page])

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
    
    if params[:notions].present?
      notion_ids = Array(params[:notions]).reject(&:blank?)
      if notion_ids.any?
        @oeuvres = @oeuvres
          .joins(:notions)
          .where(notions: { id: notion_ids })
          .group('oeuvres.id')
          .having('COUNT(DISTINCT notions.id) = ?', notion_ids.size)
      end
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
  
    case params[:sort]
      when 'nom_asc'
        @designers = @designers.reorder('designers.nom ASC')
        @oeuvres = @oeuvres.reorder('oeuvres.nom_oeuvre ASC')
      when 'nom_desc'
        @designers = @designers.reorder('designers.nom DESC')
        @oeuvres = @oeuvres.reorder('oeuvres.nom_oeuvre DESC')
      when 'oeuvre_asc'
        @oeuvres = @oeuvres.reorder('oeuvres.date_oeuvre ASC')
      when 'oeuvre_desc'
        @oeuvres = @oeuvres.reorder('oeuvres.date_oeuvre DESC')
      when 'naissance_asc'
        @designers = @designers.reorder('designers.date_naissance ASC')
      when 'naissance_desc'
        @designers = @designers.reorder('designers.date_naissance DESC')
      end


    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end 
end
