class SchoolsAdsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :authenticate_admin!, raise: false
  layout 'schools_ads'

  def index
    real_students = User.where(statut: 'etudiant').count
    @students_count = real_students.positive? && real_students >= 100 ? real_students : [User.count, 1090].max
    
    real_etablissements = User.where.not(etablissement_id: nil).distinct.count(:etablissement_id)
    @etablissements_count = real_etablissements.positive? && real_etablissements >= 50 ? real_etablissements : 130

    real_teachers = User.where(statut: 'enseignant').count
    @teachers_count = real_teachers.positive? && real_teachers >= 10 ? real_teachers : 36

    # Audience Metrics - Directement depuis la base de données
    @active_members_count = User.where(banned: [false, nil]).count
    @impressions_count = (Ad.sum(:impressions_count).to_i rescue 0)
    @std2a_count = User.where("study_level ILIKE ? OR study_level ILIKE ?", "%terminale%", "%std2a%").count

    # Données dynamiques de répartition par région pour la carte interactive
    # Basé sur le volume total de membres et la répartition réelle des établissements par région
    region_mapping = {
      "idf" => { name: "Île-de-France", db_names: ["Ile-de-France", "Île-de-France"] },
      "ara" => { name: "Auvergne-Rhône-Alpes", db_names: ["Auvergne-Rhône-Alpes"] },
      "naq" => { name: "Nouvelle-Aquitaine", db_names: ["Nouvelle-Aquitaine"] },
      "occ" => { name: "Occitanie", db_names: ["Occitanie"] },
      "hdf" => { name: "Hauts-de-France", db_names: ["Hauts-de-France"] },
      "pac" => { name: "Provence-Alpes-Côte d'Azur", db_names: ["Provence-Alpes-Côte d'Azur"] },
      "bre" => { name: "Bretagne", db_names: ["Bretagne"] },
      "ges" => { name: "Grand Est", db_names: ["Grand Est"] },
      "pdl" => { name: "Pays de la Loire", db_names: ["Pays de la Loire"] },
      "nor" => { name: "Normandie", db_names: ["Normandie"] },
      "bfc" => { name: "Bourgogne-Franche-Comté", db_names: ["Bourgogne-Franche-Comté"] },
      "cvl" => { name: "Centre-Val de Loire", db_names: ["Centre-Val de Loire"] },
      "cor" => { name: "Corse", db_names: ["Corse"] }
    }

    # Récupération du nombre réel d'établissements en base par région
    etablissements_by_region = Etablissement.group(:region).count
    total_etablissements_france = region_mapping.values.sum do |info|
      info[:db_names].sum { |reg| etablissements_by_region[reg].to_i }
    end

    total_members = @active_members_count

    @regions_data = {}
    region_mapping.each do |key, info|
      reg_etab_count = info[:db_names].sum { |reg| etablissements_by_region[reg].to_i }
      ratio = total_etablissements_france.positive? ? (reg_etab_count.to_f / total_etablissements_france) : 0.0

      count = (total_members * ratio).round
      percent = (ratio * 100).round(1)

      @regions_data[key] = {
        name: info[:name],
        count: count,
        percent: "#{percent}%",
        etablissements_count: reg_etab_count
      }
    end

    set_meta_tags(
      title: "Publicité & Acquisition Écoles de Design et Arts Appliqués | Omniscient Design",
      description: "Ciblez prioritairement et efficacement plus de 1 000 étudiants en Arts Appliqués (STD2A) et Design à travers toute la France. Formats natifs, ciblage régional et visibilité garantie.",
      keywords: "publicité écoles design, acquisition étudiants arts appliqués, std2a révisions, sponsoring design, communication écoles d'art, jpo design",
      canonical: "https://omniscientdesign.fr/schools-ads",
      og: {
        title: "Publicité & Acquisition Écoles de Design et Arts Appliqués | Omniscient Design",
        description: "Touchez directement les futurs talents du design et de l'art appliqué au cœur de leur outil de révision quotidien.",
        type: "website",
        url: "https://omniscientdesign.fr/schools-ads",
        image: ActionController::Base.helpers.image_url("landing/image-1.jpg", host: "https://omniscientdesign.fr"),
        locale: "fr_FR"
      },
      twitter: {
        card: "summary_large_image",
        title: "Publicité & Acquisition Écoles de Design et Arts Appliqués | Omniscient Design",
        description: "Ciblez les étudiants en design et arts appliqués (STD2A) sur Omniscient Design.",
        image: ActionController::Base.helpers.image_url("landing/image-1.jpg", host: "https://omniscientdesign.fr")
      }
    )
  end

  def funnel
    # Données dynamiques de répartition par région pour la carte interactive du funnel
    region_mapping = {
      "idf" => { name: "Île-de-France", db_names: ["Ile-de-France", "Île-de-France"] },
      "ara" => { name: "Auvergne-Rhône-Alpes", db_names: ["Auvergne-Rhône-Alpes"] },
      "naq" => { name: "Nouvelle-Aquitaine", db_names: ["Nouvelle-Aquitaine"] },
      "occ" => { name: "Occitanie", db_names: ["Occitanie"] },
      "hdf" => { name: "Hauts-de-France", db_names: ["Hauts-de-France"] },
      "pac" => { name: "Provence-Alpes-Côte d'Azur", db_names: ["Provence-Alpes-Côte d'Azur"] },
      "bre" => { name: "Bretagne", db_names: ["Bretagne"] },
      "ges" => { name: "Grand Est", db_names: ["Grand Est"] },
      "pdl" => { name: "Pays de la Loire", db_names: ["Pays de la Loire"] },
      "nor" => { name: "Normandie", db_names: ["Normandie"] },
      "bfc" => { name: "Bourgogne-Franche-Comté", db_names: ["Bourgogne-Franche-Comté"] },
      "cvl" => { name: "Centre-Val de Loire", db_names: ["Centre-Val de Loire"] },
      "cor" => { name: "Corse", db_names: ["Corse"] }
    }

    etablissements_by_region = Etablissement.group(:region).count
    total_etablissements_france = region_mapping.values.sum do |info|
      info[:db_names].sum { |reg| etablissements_by_region[reg].to_i }
    end

    total_members = User.where(banned: [false, nil]).count

    @regions_data = {}
    region_mapping.each do |key, info|
      reg_etab_count = info[:db_names].sum { |reg| etablissements_by_region[reg].to_i }
      ratio = total_etablissements_france.positive? ? (reg_etab_count.to_f / total_etablissements_france) : 0.0

      count = [(total_members * ratio).round, 45].max
      percent = (ratio * 100).round(1)

      @regions_data[key] = {
        name: info[:name],
        count: count,
        percent: "#{percent}%",
        etablissements_count: reg_etab_count
      }
    end

    set_meta_tags(
      title: "Créer votre campagne publicitaire | Omniscient Design",
      description: "Configurez vos visuels, votre période de diffusion et votre ancrage local pour vos campagnes publicitaires sur Omniscient Design."
    )
  end

  def contact
    @school_name = params[:school_name].to_s.strip
    @email = params[:email].to_s.strip
    @message = params[:message].to_s.strip

    if @school_name.present? && @email.present? && @message.present?
      begin
        SchoolAdsMailer.contact_email(
          school_name: @school_name,
          email: @email,
          message: @message
        ).deliver_later

        # Création notification in-app pour les administrateurs
        User.where(role: 'admin').each do |admin_user|
          Notification.create(
            user_id: admin_user.id,
            title: 'Nouvelle demande école (Schools Ads)',
            message: "Demande reçue de #{@school_name} (#{@email})",
            link: '/admin',
            status: :unread
          )
        end
      rescue StandardError => e
        Rails.logger.error("Erreur envoi SchoolAdsMailer : #{e.message}")
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to request.referer || schools_ads_path, notice: "Merci pour votre message ! Notre équipe vous répondra dans les plus brefs délais." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "schools-ads-form-feedback",
            html: %(<div class="sa-form-alert sa-form-alert--error">Veuillez renseigner tous les champs obligatoires.</div>)
          )
        end
        format.html { redirect_to request.referer || schools_ads_path, alert: "Veuillez remplir tous les champs du formulaire." }
      end
    end
  end
end
