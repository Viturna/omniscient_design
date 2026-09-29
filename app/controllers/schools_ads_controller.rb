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
    begin
      title = params[:title].presence || "Campagne Partenaire"
      description = params[:description].presence || ""
      link = params[:link].presence || "https://omniscientdesign.fr"
      school_name = params[:school_name].presence || "Établissement Partenaire"
      email = params[:email].presence || "contact@ecole-partenaire.fr"
      region = params[:region].presence || "Centre-Val de Loire"
      format_type = params[:format_type].presence || "accueil"
      
      start_date = Date.parse(params[:start_date]) rescue Date.current
      end_date = Date.parse(params[:end_date]) rescue (start_date + 1.month)
      end_date = start_date if end_date < start_date
      duration_days = (end_date - start_date).to_i + 1

      plan_type = params[:plan_type].presence || "ancrage_local"

      # Tarif forfaitaire mensuel de l'abonnement récurrent
      price_cents = if plan_type == "encart_natif"
        20000 # 200.00 EUR / mois
      else # ancrage_local
        40000 # 400.00 EUR / mois
      end

      # Gestion sécurisée du compte utilisateur
      if user_signed_in? && email.downcase == current_user.email.downcase
        # L'utilisateur connecté conserve son compte actuel
        email = current_user.email
        school_name = current_user.etablissement&.name.presence || current_user.firstname.presence || school_name
      else
        # L'utilisateur souhaite utiliser un autre compte ou n'est pas connecté
        existing_user = User.find_by(email: email.downcase)
        if existing_user.present?
          # L'utilisateur existe déjà : on vérifie son mot de passe pour sécuriser l'accès
          if params[:password].blank? || !existing_user.valid_password?(params[:password])
            return render json: {
              success: false,
              field: 'password',
              message: "Un compte existe déjà avec cette adresse email (#{email}). Veuillez saisir le bon mot de passe associé pour vous identifier."
            }, status: :unprocessable_entity
          end
        else
          # Création d'un nouveau compte avec validations strictes
          if params[:password].blank?
            return render json: {
              success: false,
              field: 'password',
              message: "Veuillez renseigner un mot de passe pour ce compte."
            }, status: :unprocessable_entity
          end

          if params[:password] != params[:password_confirmation]
            return render json: {
              success: false,
              field: 'password_confirmation',
              message: "Les mots de passe ne correspondent pas."
            }, status: :unprocessable_entity
          end

          # Vérification du format du mot de passe (6+ cars, majuscule, minuscule, chiffre, caractère spécial)
          password_pattern = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_]).{6,}\z/
          unless params[:password] =~ password_pattern
            return render json: {
              success: false,
              field: 'password',
              message: "Le mot de passe doit contenir au moins 6 caractères, avec une majuscule, une minuscule, un chiffre et un caractère spécial."
            }, status: :unprocessable_entity
          end

          # Génération d'un pseudo unique basé sur le nom de l'école/entreprise ou le mail
          base_pseudo = school_name.parameterize.underscore.presence || email.split('@').first.parameterize.underscore
          candidate_pseudo = base_pseudo
          counter = 1
          while User.exists?(pseudo: candidate_pseudo)
            candidate_pseudo = "#{base_pseudo}_#{counter}"
            counter += 1
          end

          # Recherche de l'établissement si existant
          etab_record = Etablissement.where("LOWER(name) = ?", school_name.strip.downcase).first

          user = User.new(
            email: email.downcase,
            password: params[:password],
            password_confirmation: params[:password_confirmation],
            firstname: school_name,
            pseudo: candidate_pseudo,
            etablissement: school_name,
            etablissement_id: etab_record&.id,
            statut: 'entreprise',
            role: 'user',
            rgpd_consent: true
          )
          user.skip_confirmation! if user.respond_to?(:skip_confirmation!)

          unless user.save
            error_msg = user.errors.full_messages.to_sentence
            return render json: {
              success: false,
              field: user.errors.key?(:password) ? 'password' : (user.errors.key?(:email) ? 'email' : 'school_name'),
              message: error_msg
            }, status: :unprocessable_entity
          end
        end
      end

      # Création de l'annonce Ad (Inactive / En attente de paiement)
      ad = Ad.new(
        title: title,
        description: description,
        link: link,
        email: email,
        start_date: start_date,
        end_date: end_date,
        duration_days: duration_days,
        price_paid: price_cents,
        status: 'pending',
        active: false,
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

      # Session Stripe Checkout en mode ABONNEMENT RÉCURRENT (mensuel)
      stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
      raise "Clé Stripe non configurée (STRIPE_SECRET_KEY manquante)" if stripe_key.blank?

      Stripe.api_key = stripe_key

      # Réutiliser le customer Stripe existant pour l'email si disponible
      existing_customer_id = Ad.where("LOWER(email) = ?", email.downcase)
                               .where.not(stripe_customer_id: [nil, ""])
                               .order(created_at: :desc)
                               .pluck(:stripe_customer_id)
                               .first

      session_params = {
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'eur',
            unit_amount: price_cents,
            recurring: {
              interval: 'month'
            },
            product_data: {
              name: "Abonnement Campagne Publicitaire - #{school_name}",
              description: "Diffusion continue renouvelée mensuellement (Accueil, Recherche, Quiz) - Région : #{region}",
            },
          },
          quantity: 1,
        }],
        mode: 'subscription',
        subscription_data: {
          # Si un compte connecté Stripe (ex: Edgar) est configuré dans l'ENV
          # Stripe Connect transfère automatiquement les 60% vers son compte à chaque mensualité
          # et conserve les 40% sur la plateforme pour Thomas
          **(if ENV['STRIPE_CONNECT_ACCOUNT_ID'].present?
              {
                transfer_data: {
                  destination: ENV['STRIPE_CONNECT_ACCOUNT_ID'],
                  amount_percent: (ENV['STRIPE_CONNECT_PERCENT'].presence || 60.0).to_f
                }
              }
            else
              {}
            end),
          metadata: {
            ad_id: ad.id,
            school_name: school_name,
            region: region
          }
        },
        metadata: {
          ad_id: ad.id,
          school_name: school_name,
          region: region,
          duration_days: duration_days
        },
        success_url: "#{request.base_url}#{request.subdomain.to_s.include?('schools-ads') ? '/succes' : '/schools-ads/succes'}?ad_id=#{ad.id}&session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{request.base_url}#{request.subdomain.to_s.include?('schools-ads') ? '/creer-campagne' : '/schools-ads/creer-campagne'}"
      }

      if existing_customer_id.present?
        session_params[:customer] = existing_customer_id
      else
        session_params[:customer_email] = email
      end

      session = Stripe::Checkout::Session.create(session_params)

      render json: { success: true, checkout_url: session.url }
    rescue StandardError => e
      Rails.logger.error("Checkout Error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      ad.destroy if defined?(ad) && ad.present? && ad.persisted?
      render json: { 
        success: false, 
        message: "Erreur lors de la création de la campagne : #{e.message}"
      }, status: :unprocessable_entity
    end
  end

  def success
    @ad = Ad.find_by(id: params[:ad_id])
    if @ad.present?
      # Si on a un session_id Stripe, vérification de la session
      if params[:session_id].present?
        begin
          stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
          if stripe_key.present?
            Stripe.api_key = stripe_key
            stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
            if stripe_session.payment_status == 'paid' || stripe_session.subscription.present?
              @ad.update(
                status: 'pending_validation',
                active: false,
                stripe_subscription_id: stripe_session.subscription,
                stripe_customer_id: stripe_session.customer,
                subscription_status: 'active'
              )
            end
          end
        rescue StandardError => e
          Rails.logger.error("Stripe verify session error: #{e.message}")
          @ad.update(status: 'pending_validation', active: false)
        end
      else
        @ad.update(status: 'pending_validation', active: false)
      end

      # Notification aux administrateurs une fois le paiement validé
      school_name = @ad.title.presence || "Nouvel annonceur"
      User.where(role: 'admin').each do |admin_user|
        Notification.find_or_create_by(
          user_id: admin_user.id,
          link: '/admin/ads'
        ) do |notif|
          notif.title = "Nouvel abonnement publicitaire : #{school_name}"
          notif.message = "#{school_name} a souscrit à une campagne récurrente (#{@ad.price_paid.to_i / 100}€ / mois)."
          notif.status = :unread
        end rescue nil
      end
      
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
      contact_record = SchoolContact.create(
        school_name: @school_name,
        email: @email,
        message: @message,
        request_type: @message.include?('[Demande de Devis Monopole]') ? 'devis_monopole' : 'contact'
      )

      begin
        SchoolAdsMailer.contact_email(
          school_name: @school_name,
          email: @email,
          message: @message
        ).deliver_later

        notif_title = contact_record.request_type == 'devis_monopole' ? 'Nouvelle demande de devis Monopole' : 'Nouveau contact École'
        User.where(role: 'admin').each do |admin_user|
          Notification.create(
            user_id: admin_user.id,
            title: notif_title,
            message: "#{@school_name} (#{ @email })",
            link: '/admin/school_contacts',
            status: :unread
          )
        end
      rescue StandardError => e
        Rails.logger.error("Erreur envoi SchoolAdsMailer : #{e.message}")
      end

      respond_to do |format|
        format.turbo_stream
        format.json { render json: { success: true, message: "Votre demande de devis Monopole a bien été envoyée. Notre équipe vous recontactera sous 24h ouvrées." } }
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
        format.json { render json: { success: false, error: "Veuillez remplir tous les champs obligatoires." }, status: :unprocessable_entity }
        format.html { redirect_to request.referer || schools_ads_path, alert: "Veuillez remplir tous les champs du formulaire." }
      end
    end
  end

  def billing_portal
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Veuillez vous connecter."
      return
    end

    # Trouver le customer Stripe de l'annonce ou de l'utilisateur
    customer_id = nil
    if params[:ad_id].present?
      specific_ad = Ad.find_by(id: params[:ad_id])
      if specific_ad && (specific_ad.email.to_s.downcase == current_user.email.downcase || current_user.admin?)
        customer_id = specific_ad.stripe_customer_id
      end
    end

    if customer_id.blank?
      ad_with_customer = Ad.where("LOWER(email) = ?", current_user.email.downcase)
                           .where.not(stripe_customer_id: [nil, ""])
                           .order(created_at: :desc)
                           .first
      customer_id = ad_with_customer&.stripe_customer_id
    end

    if customer_id.blank?
      redirect_to schools_ads_dashboard_path, alert: "Aucun historique de facturation Stripe trouvé pour ce compte."
      return
    end

    begin
      stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
      Stripe.api_key = stripe_key

      return_url = request.subdomain.to_s.include?('schools-ads') ? "#{request.base_url}/dashboard" : "#{request.base_url}/schools-ads/dashboard"

      portal_session = Stripe::BillingPortal::Session.create({
        customer: customer_id,
        return_url: return_url
      })

      redirect_to portal_session.url, allow_other_host: true
    rescue StandardError => e
      Rails.logger.error("Erreur Stripe Billing Portal: #{e.message}")
      redirect_to schools_ads_dashboard_path, alert: "Impossible d'accéder au portail de facturation : #{e.message}"
    end
  end

  def cancel_subscription
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Veuillez vous connecter."
      return
    end

    @ad = Ad.find_by(id: params[:id])
    if @ad.nil? || (@ad.email.to_s.downcase != current_user.email.to_s.downcase && !current_user.admin?)
      redirect_to schools_ads_dashboard_path, alert: "Campagne introuvable ou non autorisée."
      return
    end

    if @ad.stripe_subscription_id.present?
      begin
        stripe_key = ENV['STRIPE_SECRET_KEY'].presence || Stripe.api_key.presence
        if stripe_key.present?
          Stripe.api_key = stripe_key
          # Annulation à la fin de la période en cours (cancel_at_period_end) pour laisser la diffusion payée active jusqu'au bout
          Stripe::Subscription.update(
            @ad.stripe_subscription_id,
            { cancel_at_period_end: true }
          )
        end
        @ad.update(subscription_status: 'canceling')
        flash[:notice] = "Votre abonnement publicitaire a été résilié. Votre campagne restera diffusée jusqu'à la fin de la période mensuelle en cours."
      rescue StandardError => e
        Rails.logger.error("Erreur résiliation Stripe: #{e.message}")
        @ad.update(subscription_status: 'canceling')
        flash[:notice] = "Votre demande de résiliation a bien été prise en compte."
      end
    else
      @ad.update(subscription_status: 'canceled', active: false)
      flash[:notice] = "Votre campagne a bien été résiliée."
    end

    redirect_to request.referer || schools_ads_dashboard_path
  end
end
