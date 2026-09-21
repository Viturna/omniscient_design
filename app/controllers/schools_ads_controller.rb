require 'stripe'

class SchoolsAdsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :authenticate_admin!, raise: false
  skip_before_action :verify_authenticity_token, only: [:checkout, :contact], raise: false
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

  def checkout
    title = params[:title].presence || "Campagne Partenaire"
    description = params[:description].presence || ""
    link = params[:link].presence || "https://omniscientdesign.fr"
    school_name = params[:school_name].presence || "Établissement Partenaire"
    email = params[:email].presence || "contact@ecole-partenaire.fr"
    region = params[:region].presence || "Centre-Val de Loire"
    format_type = params[:format_type].presence || "accueil"
    
    start_date = Date.parse(params[:start_date]) rescue Date.current
    end_date = Date.parse(params[:end_date]) rescue (start_date + 24.days)
    end_date = start_date if end_date < start_date
    duration_days = (end_date - start_date).to_i + 1

    plan_type = params[:plan_type].presence || "ancrage_local"

    # Calcul du tarif selon la formule
    price_cents = if plan_type == "encart_natif"
      if duration_days >= 25
        20000 # 200.00 EUR forfait mois
      elsif duration_days >= 7
        6000  # 60.00 EUR forfait semaine
      else
        [duration_days * 1000, 3000].max # 10€/jour, min 30€
      end
    else # ancrage_local
      if duration_days >= 25
        40000 # 400.00 EUR forfait mois
      elsif duration_days >= 7
        12000 # 120.00 EUR forfait semaine
      else
        [duration_days * 2000, 5000].max # 20€/jour, min 50€
      end
    end

    # Création du compte utilisateur pro si mot de passe fourni
    if params[:password].present? && params[:password] == params[:password_confirmation]
      user = User.find_by(email: email.downcase)
      if user.nil?
        user = User.new(
          email: email.downcase,
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          firstname: school_name,
          etablissement: school_name,
          statut: 'organisme',
          role: 'user'
        )
        user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
        user.save
      end
    end

    # Création de l'annonce Ad
    ad = Ad.new(
      title: title,
      description: description,
      link: link,
      email: email,
      start_date: start_date,
      end_date: end_date,
      duration_days: duration_days,
      price_paid: price_cents,
      status: 'pending_validation',
      active: true,
      weight: 1
    )

    if params[:image].present?
      ad.image.attach(params[:image])
    end
    if params[:image_mobile].present?
      ad.image_mobile.attach(params[:image_mobile])
    end

    unless ad.image.attached?
      placeholder_path = Rails.root.join('app', 'assets', 'images', 'landing', 'image-1.jpg')
      if File.exist?(placeholder_path)
        ad.image.attach(io: File.open(placeholder_path), filename: 'default_ad.jpg', content_type: 'image/jpeg')
      end
    end

    ad.save(validate: false)

    # Notification aux administrateurs
    User.where(role: 'admin').each do |admin_user|
      Notification.create(
        user_id: admin_user.id,
        title: "Nouvelle campagne publicitaire : #{school_name}",
        message: "#{school_name} a commandé une campagne de #{duration_days} jours (#{price_cents / 100}€).",
        link: '/admin/ads',
        status: :unread
      ) rescue nil
    end

    # Session Stripe Checkout
    begin
      stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
      raise "Clé Stripe non configurée (STRIPE_SECRET_KEY manquante)" if stripe_key.blank?

      Stripe.api_key = stripe_key

      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'eur',
            unit_amount: price_cents,
            product_data: {
              name: "Campagne Publicitaire Omniscient Design - #{school_name}",
              description: "#{duration_days} jours de diffusion (#{format_type.capitalize}) - Région : #{region}",
            },
          },
          quantity: 1,
        }],
        mode: 'payment',
        customer_email: email,
        metadata: {
          ad_id: ad.id,
          school_name: school_name,
          region: region,
          duration_days: duration_days
        },
        success_url: "#{request.base_url}#{request.subdomain.to_s.include?('schools-ads') ? '/succes' : '/schools-ads/succes'}?ad_id=#{ad.id}&session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{request.base_url}#{request.subdomain.to_s.include?('schools-ads') ? '/creer-campagne' : '/schools-ads/creer-campagne'}"
      })

      render json: { success: true, checkout_url: session.url }
    rescue StandardError => e
      Rails.logger.error("Stripe Checkout Error: #{e.message}")
      render json: { 
        success: false, 
        message: "Erreur lors de la redirection vers Stripe : #{e.message}"
      }, status: :unprocessable_entity
    end
  end

  def success
    @ad = Ad.find_by(id: params[:ad_id])
    if @ad.present?
      @ad.update(status: 'pending_validation')
      
      # Connexion automatique de l'annonceur
      if !user_signed_in? && @ad.email.present?
        user = User.find_by(email: @ad.email.downcase)
        sign_in(user, scope: :user) if user.present?
      end
    end

    set_meta_tags(
      title: "Campagne confirmée ! | Omniscient Design",
      description: "Votre campagne a été enregistrée avec succès. Notre équipe valide vos visuels sous 24h."
    )
  end

  def dashboard
    unless user_signed_in?
      flash[:alert] = "Veuillez vous connecter pour accéder à votre espace annonceur."
      redirect_to new_user_session_path
      return
    end

    @user = current_user
    @ads = Ad.where("LOWER(email) = ?", @user.email.downcase).order(created_at: :desc)
    
    # Pour les administrateurs qui testent sans annonce personnelle
    if @user.admin? && @ads.empty?
      @ads = Ad.all.order(created_at: :desc).limit(10)
    end

    @total_impressions = @ads.sum(:impressions_count).to_i
    @total_clicks = @ads.sum(:clicks_count).to_i
    @avg_ctr = @total_impressions.positive? ? ((@total_clicks.to_f / @total_impressions) * 100).round(2) : 0
    @active_ads_count = @ads.count { |ad| ad.currently_running? }
    @pending_ads_count = @ads.where(status: 'pending_validation').count

    set_meta_tags(
      title: "Espace Annonceur & Suivi des Campagnes | Omniscient Design",
      description: "Gérez vos publicités et suivez les performances de vos campagnes en direct sur Omniscient Design."
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
