class SearchController < ApplicationController
  include ApplicationHelper
  # 1. AJOUT : Nécessaire pour utiliser url_for
  include Rails.application.routes.url_helpers

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

    # 2. MODIFIÉ : On pré-charge les associations pour la performance
    oeuvres = Oeuvre.where(validation: true)
                    .where("nom_oeuvre ILIKE ?", "%#{query}%")
                    .includes(oeuvre_images: { file_attachment: :blob }, designers: [])
                    .limit(5)
              
    studios = Studio.where(validation: true)
                    .where("nom ILIKE ?", "%#{query}%")
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
         first_image = o.designer_images.first
          thumb_url = nil

          if first_image&.file&.attached?
            begin
              thumb_url = url_for(first_image.file.variant(:thumb))
            rescue ActiveStorage::FileNotFoundError => e
              # Si le fichier est cassé (comme dans vos logs), on ne plante pas
              Rails.logger.error "[Autocomplete] Fichier manquant pour Designer ID #{o.id}: #{e.message}"
            end
          end
          {
            name: d.nom_designer,
            url: designer_path(d),
            img: img_url
          }
        end
      },

      # 3. MODIFIÉ : Remplacement de l'ancienne logique par Active Storage
      oeuvres: {
        title: t('search.references'),
        class: "section-title",
        results: oeuvres.map do |o|
          
          first_image = o.oeuvre_images.first
          thumb_url = nil

          if first_image&.file&.attached?
            begin
              # On génère l'URL pour le variant :thumb
              thumb_url = url_for(first_image.file.variant(:thumb))
            rescue ActiveStorage::FileNotFoundError => e
              # Si le fichier est cassé (comme dans vos logs), on ne plante pas
              Rails.logger.error "[Autocomplete] Fichier manquant pour Oeuvre ID #{o.id}: #{e.message}"
            end
          end

          {
            name: o.nom_oeuvre,
            url: oeuvre_path(o),
            thumb: thumb_url, # <- C'est la clé que votre JS attend
            designer: o.designers.map(&:nom_designer).join(', ') # <- Votre JS gère ça
          }
        end
      },
      studios: {
        title: t('search.studios', default: "Studios"), # Assurez-vous d'avoir la trad
        class: "section-title",
        results: studios.map do |s|
          # Gestion de l'image studio (similaire à designer)
          thumb_path = Rails.root.join("app/assets/images/studios/thumbs/#{remove_accents_and_special_chars(s.nom)}.webp")
          img_url = if File.exist?(thumb_path)
                      "/assets/studios/thumbs/#{remove_accents_and_special_chars(s.nom)}.webp"
                    else
                      s.image # ou une image par défaut
                    end
          {
            name: s.nom,
            url: studio_path(s),
            img: img_url
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

    studio = Studio.where(validation: true).where("nom ILIKE ?", query).first

    if studio
      redirect_to studio_path(studio) and return
    end
    # Si on a un designer dont le nom/prénom correspond quasi-exactement, on redirige vers lui
    if designer && (oeuvre.nil? || query.length <= designer.nom.length)
      redirect_to designer_path(designer) and return
    end

    # Sinon si on a une oeuvre, on redirige vers elle
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
                        .select(:id, :nom, :date_creation, :image, :slug)
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
    # Supprime les includes qui polluent la requête
    @oeuvres = @oeuvres.except(:includes)

    @oeuvres = @oeuvres
      .joins(:notions)
      .where(notions: { id: notion_ids })
      .group('oeuvres.id')
      .select('oeuvres.*')
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
      if start_year > 0 && end_year > 0 && start_year <= end_year
         @studios = @studios.where("date_creation >= ? AND (date_fin IS NULL OR date_fin <= ?)", start_year, end_year)
       end
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