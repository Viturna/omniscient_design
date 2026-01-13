class SearchController < ApplicationController
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  def autocomplete
    query = params[:query].to_s.strip

    if query.length < 2
      return render json: { error: "Query too short" }, status: :bad_request
    end

    # 1. Domaines : Insensible aux accents
    domaines = Domaine.where("unaccent(domaine) ILIKE unaccent(?)", "%#{query}%").limit(5)
    
    # 2. Designers : Insensible aux accents (Prénom, Nom, Concaténation)
    designers = Designer.where(validation: true).where(
      "unaccent(prenom) ILIKE unaccent(:q) OR unaccent(nom) ILIKE unaccent(:q) OR unaccent(prenom || ' ' || nom) ILIKE unaccent(:q) OR unaccent(nom || ' ' || prenom) ILIKE unaccent(:q)",
      q: "%#{query}%"
    ).includes(designer_images: { file_attachment: :blob }).limit(5)

    # 3. Œuvres : Insensible aux accents
    oeuvres = Oeuvre.where(validation: true)
                    .where("unaccent(nom_oeuvre) ILIKE unaccent(?)", "%#{query}%")
                    .includes(oeuvre_images: { file_attachment: :blob }, designers: [])
                    .limit(5)
    
    # 4. Studios : Insensible aux accents
    studios = Studio.where(validation: true)
                    .where("unaccent(nom) ILIKE unaccent(?)", "%#{query}%")
                    .includes(studio_images: { file_attachment: :blob })
                    .limit(5)

    render json: {
      domaines: {
        title: t('search.domains'),
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
        title: t('search.designers'),
        class: "section-title",
        results: designers.map do |d|
          first_image = d.designer_images.first
          thumb_url = nil

          if first_image&.file&.attached?
            begin
              thumb_url = url_for(first_image.file.variant(:thumb))
            rescue ActiveStorage::FileNotFoundError => e
              Rails.logger.error "[Autocomplete] Fichier manquant pour Designer ID #{d.id}: #{e.message}"
            end
          end
          {
            name: d.nom_designer,
            url: designer_path(d),
            img: thumb_url
          }
        end
      },

      oeuvres: {
        title: t('search.references'),
        class: "section-title",
        results: oeuvres.map do |o|
          first_image = o.oeuvre_images.first
          thumb_url = nil

          if first_image&.file&.attached?
            begin
              thumb_url = url_for(first_image.file.variant(:thumb))
            rescue ActiveStorage::FileNotFoundError => e
              Rails.logger.error "[Autocomplete] Fichier manquant pour Oeuvre ID #{o.id}: #{e.message}"
            end
          end

          {
            name: o.nom_oeuvre,
            url: oeuvre_path(o),
            img: thumb_url,
          }
        end
      },
      studios: {
        title: t('search.studios', default: "Studios"),
        class: "section-title",
        results: studios.map do |s|
           first_image = s.studio_images.first
            thumb_url = nil

            if first_image&.file&.attached?
              begin
                thumb_url = url_for(first_image.file.variant(:thumb))
              rescue ActiveStorage::FileNotFoundError => e
                Rails.logger.error "[Autocomplete] Fichier manquant pour Studio ID #{s.id}: #{e.message}"
              end
            end
          {
            name: s.nom,
            url: studio_path(s),
            img: thumb_url 
          }
        end
      }
    }
  rescue => e
    Rails.logger.error "[Autocomplete] Erreur: #{e.message}"
    render json: { error: t('search.server_error') }, status: 500
  end

  def search
    @current_page = 'recherche'
    per_page = (params[:per_page] || 24).to_i  
    @countries = Country.where(id: DesignerCountry.select(:country_id))
                        .or(Country.where(id: StudioCountry.select(:country_id)))
                        .distinct
                        .order(:country)
    @notions = Notion.all
    query = params[:query].to_s.strip
  
    if query.present?
      designer = Designer.where(validation: true)
        .where("unaccent(prenom) ILIKE unaccent(:q) OR unaccent(nom) ILIKE unaccent(:q) OR unaccent(prenom || ' ' || nom) ILIKE unaccent(:q) OR unaccent(nom || ' ' || prenom) ILIKE unaccent(:q)", q: "%#{query}%")
        .order(
          Arel.sql("CASE WHEN unaccent(nom) ILIKE unaccent(#{ActiveRecord::Base.connection.quote(query)}) THEN 0 ELSE 1 END, nom ASC")
        )
        .first

      oeuvre = Oeuvre.where(validation: true)
        .where("unaccent(nom_oeuvre) ILIKE unaccent(?)", "%#{query}%")
        .order(
          Arel.sql("CASE WHEN unaccent(nom_oeuvre) ILIKE unaccent(#{ActiveRecord::Base.connection.quote(query)}) THEN 0 ELSE 1 END, nom_oeuvre ASC")
        )
        .first

      studio = Studio.where(validation: true).where("unaccent(nom) ILIKE unaccent(?)", query).first

      if studio
        redirect_to studio_path(studio) and return
      end
      if designer && (oeuvre.nil? || query.length <= designer.nom.length)
        redirect_to designer_path(designer) and return
      end

      if oeuvre
        redirect_to oeuvre_path(oeuvre) and return
      end
    end

    if params[:tab] == "frise"
      @oeuvres = Oeuvre.where(validation: true)
                      .select(:id, :nom_oeuvre, :date_oeuvre, :slug)
                      .includes(:notions, :designers, :domaines)
                      .order(:date_oeuvre)

      @designers = Designer.where(validation: true)
                          .select(:id, :nom, :prenom, :date_naissance, :slug)
                          .includes(:domaines, :countries)
                          .order(:date_naissance)
                        
      @studios = Studio.where(validation: true)
                          .select(:id, :nom, :date_creation, :slug)
                          .includes(:domaines, :countries)
                          .order(:date_creation)
    else
      @oeuvres = Oeuvre.where(validation: true)
                      .select(:id, :nom_oeuvre, :date_oeuvre, :slug)
                      .includes(:notions, :domaines)
                      .order(:nom_oeuvre)
                      .page(params[:page])
                      .per(per_page)

      @designers = Designer.where(validation: true)
                       .select(:id, :nom, :prenom, :date_naissance, :slug)
                       .includes(:domaines, :countries)
                       .order(:nom)
                       .page(params[:page])
                       .per(per_page)

      @studios = Studio.where(validation: true)
                          .select(:id, :nom, :date_creation, :slug)
                          .includes(:domaines, :countries)
                          .order(:nom)
                          .page(params[:page])
                          .per(per_page)
    end

    if params[:domaine].present?
      filtered_domains = Array(params[:domaine]).reject(&:blank?)
      if filtered_domains.any?
        @oeuvres = @oeuvres.joins(:domaines).where(domaines: { id: filtered_domains })
        @designers = @designers.joins(:domaines).where(domaines: { id: filtered_domains })
        @studios = @studios.joins(:domaines).where(domaines: { id: filtered_domains })
      end
    end

    if params[:country].present?
      countries = Array(params[:country]).reject(&:blank?)
      if countries.any?
        @designers = @designers.joins(:countries).where(countries: { id: countries })
        @studios = @studios.joins(:countries).where(countries: { id: countries })
        designer_ids = @designers.pluck(:id)
        @oeuvres     = @oeuvres.joins(:designers)
                                .where(designers: { id: designer_ids })
      end
    end

    if params[:notions].present?
      notion_ids = Array(params[:notions]).reject(&:blank?)
      if notion_ids.any?
        @oeuvres = @oeuvres.except(:includes)
        @oeuvres = @oeuvres
          .joins(:notions)
          .where(notions: { id: notion_ids })
          .group('oeuvres.id')
          .select('oeuvres.*')
          .having('COUNT(DISTINCT notions.id) = ?', notion_ids.size)
      end
    end

    # --- MODIFICATION START : GESTION DES DATES INDÉPENDANTES ---
    current_year = Time.now.year

    if params[:start_year].present? && params[:end_year].present?
      # CAS 1 : L'utilisateur a filtré par dates. Tout le monde s'aligne.
      start_year = params[:start_year].to_i
      end_year = params[:end_year].to_i
    
      if start_year > 0 && end_year > 0 && start_year <= end_year
        @designers = @designers.where("date_naissance BETWEEN ? AND ?", start_year, end_year)
        @oeuvres = @oeuvres.where("date_oeuvre BETWEEN ? AND ?", start_year, end_year)
        @studios = @studios.where("date_creation >= ? AND (date_fin IS NULL OR date_fin <= ?)", start_year, end_year)
        
        # On définit 3 variables, mais elles ont la même plage car l'utilisateur a filtré
        timeline_range = (start_year..end_year).to_a
        @designers_timeline_years = timeline_range
        @oeuvres_timeline_years = timeline_range
        @studios_timeline_years = timeline_range
        @timeline_years = timeline_range # Backup pour compatibilité
      else
        # Fallback si dates invalides
        fallback_range = (1880..current_year).to_a
        @designers_timeline_years = fallback_range
        @oeuvres_timeline_years = fallback_range
        @studios_timeline_years = fallback_range
        @timeline_years = fallback_range
      end
    else
      # CAS 2 : Pas de filtre date. On calcule dynamiquement le début pour CHAQUE catégorie.
      
      # Pour les designers
      min_designer = @designers.minimum(:date_naissance) || 1880
      @designers_timeline_years = (min_designer..current_year).to_a

      # Pour les oeuvres
      min_oeuvre = @oeuvres.minimum(:date_oeuvre) || 1880
      @oeuvres_timeline_years = (min_oeuvre..current_year).to_a

      # Pour les studios
      min_studio = @studios.minimum(:date_creation) || 1880
      @studios_timeline_years = (min_studio..current_year).to_a
      
      # Variable globale pour éviter les erreurs de vue (prend le min global par défaut)
      global_min = [min_designer, min_oeuvre, min_studio].min
      @timeline_years = (global_min..current_year).to_a
    end
    # --- MODIFICATION END ---
  
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