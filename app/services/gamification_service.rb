class GamificationService
  def initialize(user)
    @user = user
  end

  # --- 1. BADGES SPÉCIAUX ---

  # "Omniscient User" : Se créer un compte
  def check_omniscient_user
    assign_badge(name: "Omniscient User", category: "special")
  end

  # "Early Adopter" : Faire partie des 100 premiers comptes
  def check_early_adopter
    if @user.id <= 100
      assign_badge(name: "Early Adopter", category: "special")
    end
  end

  # "Community Member" : S'abonner aux réseaux
  # À appeler quand l'user clique sur un lien social
  def check_community_member
    assign_badge(name: "Community Member", category: "special")
  end

  # "Dans les moindres détails" : Bouton caché
  def check_detail_finder
    assign_badge(name: "Dans les moindres détails", category: "special")
  end

  # "Noctambule" : Connecté entre 00h et 5h
  def check_noctambule
  return if @user.badges.exists?(name: "Noctambule")
  
  heure_actuelle = Time.current.in_time_zone("Europe/Paris").hour

  if heure_actuelle >= 0 && heure_actuelle < 5
    assign_badge(name: "Noctambule", category: "special")
  end
end

  # "Multi support" : Avoir l'app (Utilisation de UserDevice)
  def check_multi_support
    if @user.user_devices.any?
      assign_badge(name: "Multi support", category: "special")
    end
  end

  # --- 2. BADGES À NIVEAUX ---

  # "Donateur" : Appelé manuellement ou via webhook paiement
  # amount en euros
  def check_donor(amount_total)
    # Badge Spécial "Donateur" (Peu importe le montant)
    assign_badge(name: "Donateur", category: "special") if amount_total > 0

    # Niveaux
    assign_badge_by_level("donor", amount_total, {
      5 => "bronze",
      20 => "silver",
      50 => "gold"
    })
  end

  # "Contributeur" : Basé sur les références validées (Table Suivi)
  def check_contributor
    # On compte les oeuvres + designers + studios validés (ou juste oeuvres selon ton choix)
    # Ici j'utilise le compteur global du modèle Suivi s'il existe
    count = @user.suivis.first&.nb_references_validees || 0
    
    # Si tu veux compter manuellement :
    # count = @user.oeuvres.where(validation: true).count

    assign_badge_by_level("contributor", count, {
      1 => "bronze",
      10 => "silver",
      20 => "gold"
    })
  end

  # "Ambassadeur" : Parrainages (Referral)
  def check_ambassador
    count = @user.referrals_as_referrer.count # Ou count des rewards claimed

    assign_badge_by_level("ambassador", count, {
      3 => "bronze",
      10 => "silver",
      20 => "gold"
    })
  end

  # "Investigateur" : Feedbacks + Bug Reports
  def check_investigator
    count = @user.feedbacks.count + @user.bug_reports.count

    assign_badge_by_level("investigator", count, {
      1 => "bronze",
      5 => "silver",
      10 => "gold"
    })
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
    
    thresholds.each do |score_needed, level|
      if user_score >= score_needed
        badge = Badge.find_by(category: category, level: level)
        give_badge(badge) if badge
      end
    end
  end

  def give_badge(badge)
    unless @user.badges.include?(badge)
      UserBadge.create(user: @user, badge: badge)
      
      Notification.create(
        user: @user,
        title: "Nouveau Badge !",
        message: "Félicitations ! Tu as débloqué le badge : #{badge.name}",
        link: "/mes-badges",
        status: :unread
      )
    end
  end
  def self.manual_assign(user, badge)
    return false if user.badges.include?(badge)

    UserBadge.create(user: user, badge: badge)
    
    Notification.create(
      user: user,
      title: "Badge Spécial Reçu !",
      message: "L'équipe vous a décerné le badge : #{badge.name}",
      link: "/mes-badges",
      status: :unread
    )
    true
  end
end