class GamificationService
  def initialize(user)
    @user = user
  end

  # --- 1. BADGES SPÉCIAUX ---

  # "Omniscient User" : Se créer un compte
  def check_omniscient_user
    assign_badge(name: 'Omniscient User', category: 'special')
  end

  # "Early Adopter" : Faire partie des 100 premiers comptes
  def check_early_adopter
    return unless @user.id <= 100

    assign_badge(name: 'Early Adopter', category: 'special')
  end

  # "Pionnier" : Faire partie des 1000 premiers comptes
  def check_early_adopter_2
    return unless @user.id <= 1000

    assign_badge(name: 'Pionnier', category: 'special')
  end

  # "Community Member" : S'abonner aux réseaux
  # À appeler quand l'user clique sur un lien social
  def check_community_member
    assign_badge(name: 'Community Member', category: 'special')
  end

  # "Dans les moindres détails" : Bouton caché
  def check_detail_finder
    assign_badge(name: 'Dans les moindres détails', category: 'special')
  end

  # "Noctambule" : Connecté entre 00h et 5h
  def check_noctambule
    return if @user.badges.exists?(name: 'Noctambule')

    heure_actuelle = Time.current.in_time_zone('Europe/Paris').hour

    return unless heure_actuelle >= 0 && heure_actuelle < 5

    assign_badge(name: 'Noctambule', category: 'special')
  end

  # "Multi support" : Avoir l'app (Utilisation de UserDevice)
  def check_multi_support
    return unless @user.user_devices.any?

    assign_badge(name: 'Multi support', category: 'special')
  end

  # "Omniscient Supporter" : Clic sur le lien de notation
  def check_omniscient_supporter
    badge = Badge.find_or_create_by!(name: 'Omniscient Supporter') do |b|
      b.category = :special
      b.level = :standard
      b.description = "Merci d'avoir noté l'application sur les stores !"
      b.image_name = 'omniscient_supporter.webp'
    end
    give_badge(badge)
  end

  # "L'Aaaancien" : Un an d'ancienneté
  def check_seniority
    badge = Badge.find_or_create_by!(name: "L'Aaaancien") do |b|
      b.category = :special
      b.level = :standard
      b.description = "Un an d'ancienneté sur la plateforme. Un vrai pilier !"
      b.image_name = 'l_aaaancien.webp'
    end

    return unless @user.created_at <= 1.year.ago

    give_badge(badge)
  end

  # "Artchiv'eur" : Connexion OAuth depuis Artchiv' (ou Archiv)
  def check_artchiveur(application_name: nil)
    # Vérifie soit via le nom de l'app passé en paramètre,
    # soit en cherchant si l'user a un token ou grant actif depuis une app Archiv / Artchiv
    is_artchiv = if application_name.present?
                   app_name = application_name.to_s.downcase
                   app_name.include?('artchiv') || app_name.include?('archiv')
                 else
                   Doorkeeper::AccessToken
                     .joins("INNER JOIN oauth_applications ON oauth_applications.id = oauth_access_tokens.application_id")
                     .where("LOWER(oauth_applications.name) LIKE ? OR LOWER(oauth_applications.name) LIKE ?", '%artchiv%', '%archiv%')
                     .where(resource_owner_id: @user.id)
                     .where(revoked_at: nil)
                     .exists? ||
                   Doorkeeper::AccessGrant
                     .joins("INNER JOIN oauth_applications ON oauth_applications.id = oauth_access_grants.application_id")
                     .where("LOWER(oauth_applications.name) LIKE ? OR LOWER(oauth_applications.name) LIKE ?", '%artchiv%', '%archiv%')
                     .where(resource_owner_id: @user.id)
                     .where(revoked_at: nil)
                     .exists?
                 end

    return unless is_artchiv

    # Auto-création du badge s'il n'existe pas encore en DB (ex: migration non jouée en prod)
    badge = Badge.find_or_create_by!(name: "Artchiv'eur") do |b|
      b.category = :special
      b.level = :standard
      b.description = "Ton compte Omniscient Design est connecté à Artchiv'."
      b.image_name = 'archiveur.webp'
    end

    give_badge(badge)
  end

  # --- 2. BADGES À NIVEAUX ---

  # "Donateur" : Appelé manuellement ou via webhook paiement
  # amount en euros
  def check_donor(amount_total)
    # Badge Spécial "Donateur" (Peu importe le montant)
    assign_badge(name: 'Donateur', category: 'special') if amount_total > 0

    # Niveaux
    assign_badge_by_level('donor', amount_total, {
                            5 => 'bronze',
                            20 => 'silver',
                            50 => 'gold'
                          })
  end

  # "Contributeur" : Basé sur les références validées (Table Suivi)
  def check_contributor
    # On compte les references + designers + studios validés (ou juste references selon ton choix)
    # Ici j'utilise le compteur global du modèle Suivi s'il existe
    count = @user.suivis.first&.nb_references_validees || 0

    # Si tu veux compter manuellement :
    # count = @user.references.where(validation: true).count

    assign_badge_by_level('contributor', count, {
                            1 => 'bronze',
                            10 => 'silver',
                            20 => 'gold'
                          })
  end

  # "Ambassadeur" : Parrainages (Referral)
  def check_ambassador
    count = @user.referrals_as_referrer.count # Ou count des rewards claimed

    assign_badge_by_level('ambassador', count, {
                            3 => 'bronze',
                            10 => 'silver',
                            20 => 'gold'
                          })
  end

  # "Investigateur" : Feedbacks + Bug Reports
  def check_investigator
    count = @user.feedbacks.count + @user.bug_reports.count

    assign_badge_by_level('investigator', count, {
                            1 => 'bronze',
                            5 => 'silver',
                            10 => 'gold'
                          })
  end

  def check_gamer
    points = @user.quiz_points || 0

    assign_badge_by_level('gamer', points, {
                            500 => 'bronze',
                            1000 => 'silver',
                            2500 => 'gold'
                          })
  end

  # Retourne la valeur brute actuelle de l'utilisateur pour une catégorie
  def current_stat_for(category)
    case category.to_s
    when 'gamer'
      @user.quiz_points || 0
    when 'contributor'
      @user.suivis.first&.nb_references_validees || 0
    when 'ambassador'
      @user.referrals_as_referrer.count
    when 'investigator'
      @user.feedbacks.count + @user.bug_reports.count
    when 'donor'
      0
    when 'competitor'
      points = @user.quiz_points || 0
      return 0 if points <= 0
      User.where('quiz_points > ?', points).count + 1
    else
      0
    end
  end

  # Retourne les informations de progression détaillées pour un badge précis
  def progress_for_badge(badge)
    return nil if badge.special? || badge.donor? || badge.threshold.to_i <= 0

    unit = case badge.category.to_s
           when 'gamer' then 'pts'
           when 'contributor' then 'contrib.'
           when 'ambassador' then 'filleuls'
           when 'investigator' then 'retours'
           when 'competitor' then 'rang'
           else ''
           end

    target = badge.threshold.to_i

    if badge.competitor?
      current_rank = current_stat_for('competitor')
      if current_rank > 0 && current_rank <= target
        {
          current: current_rank,
          target: target,
          percentage: 100,
          unit: unit,
          label: "Top #{target} atteint (#Rank #{current_rank})"
        }
      else
        {
          current: current_rank,
          target: target,
          percentage: 0,
          unit: unit,
          label: current_rank > 0 ? "Actuellement Top #{current_rank}" : "Pas encore classé"
        }
      end
    else
      current = current_stat_for(badge.category)
      percentage = [((current.to_f / target) * 100).round, 100].min

      {
        current: current,
        target: target,
        percentage: percentage,
        unit: unit,
        label: "#{current} / #{target} #{unit}".strip
      }
    end
  end

  # Retourne les informations de progression vers le prochain palier pour une catégorie
  def next_badge_progress(category = 'gamer')
    case category.to_s
    when 'gamer'
      points = @user.quiz_points || 0
      thresholds = [
        { points: 500, level: 'bronze', name: 'Gamer Bronze' },
        { points: 1000, level: 'silver', name: 'Gamer Argent' },
        { points: 2500, level: 'gold', name: 'Gamer Or' }
      ]

      next_step = thresholds.find { |t| points < t[:points] }
      return nil unless next_step

      badge = Badge.find_by(category: 'gamer', level: next_step[:level])
      prev_points = thresholds.take_while { |t| points >= t[:points] }.last&.[](:points) || 0

      {
        badge: badge,
        badge_name: badge&.name || next_step[:name],
        current: points,
        target: next_step[:points],
        remaining: next_step[:points] - points,
        percentage: [((points - prev_points).to_f / (next_step[:points] - prev_points) * 100).round, 99].min,
        image_name: badge&.image_name || 'gamer_bronze.webp'
      }
    when 'contributor'
      count = @user.suivis.first&.nb_references_validees || 0
      thresholds = [
        { count: 1, level: 'bronze' },
        { count: 10, level: 'silver' },
        { count: 20, level: 'gold' }
      ]
      next_step = thresholds.find { |t| count < t[:count] }
      return nil unless next_step

      badge = Badge.find_by(category: 'contributor', level: next_step[:level])
      {
        badge: badge,
        badge_name: badge&.name || "Contributeur #{next_step[:level].capitalize}",
        current: count,
        target: next_step[:count],
        remaining: next_step[:count] - count,
        percentage: [(count.to_f / next_step[:count] * 100).round, 99].min,
        image_name: badge&.image_name || 'contributeur_bronze.webp'
      }
    else
      nil
    end
  end

  # "Compétiteur" : Top 1, Top 2, Top 3 du classement général
  def check_competitor
    points = @user.quiz_points || 0
    return if points <= 0

    rank = User.where('quiz_points > ?', points).count + 1

    if rank <= 3
      badge = Badge.find_by(category: 'competitor', level: 'bronze')
      give_badge(badge) if badge
    end

    if rank <= 2
      badge = Badge.find_by(category: 'competitor', level: 'silver')
      give_badge(badge) if badge
    end

    return unless rank <= 1

    badge = Badge.find_by(category: 'competitor', level: 'gold')
    give_badge(badge) if badge
  end

  private

  # Méthode générique pour attribuer un badge unique par nom
  def assign_badge(name:, category:)
    badge = Badge.find_by(name: name)
    return unless badge

    give_badge(badge)
  end

  # Méthode intelligente pour les niveaux
  def assign_badge_by_level(category, user_score, thresholds)
    # thresholds = { 1 => "bronze", 10 => "silver" }
    awarded_badges = []

    thresholds.each do |score_needed, level|
      if user_score >= score_needed
        badge = Badge.find_by(category: category, level: level)
        if badge && give_badge(badge)
          awarded_badges << badge
        end
      end
    end

    awarded_badges
  end

  def give_badge(badge)
    return false if @user.badges.include?(badge)

    user_badge = UserBadge.create(user: @user, badge: badge)
    return false unless user_badge.persisted?

    Notification.create(
      user: @user,
      title: 'Nouveau Badge !',
      message: "Félicitations ! Tu as débloqué le badge : #{badge.name}",
      link: '/mes-badges',
      status: :unread
    )
    badge
  end

  def self.manual_assign(user, badge)
    return false if user.badges.include?(badge)

    UserBadge.create(user: user, badge: badge)

    Notification.create(
      user: user,
      title: 'Badge Spécial Reçu !',
      message: "L'équipe t'a décerné le badge : #{badge.name}",
      link: '/mes-badges',
      status: :unread
    )
    true
  end
end
