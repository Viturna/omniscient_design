class User < ApplicationRecord
  before_create :generate_referral_code

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2, :apple]

  # Attributs
  attribute :banned, :boolean, default: false

  # Validations Mot de passe
  validates :password, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_]).{6,}\z/,
    message: "doit contenir au moins 6 caractères, avec une majuscule, une minuscule, un chiffre et un caractère spécial"
  }, if: :password_required?

  # Constantes
  STATUTS = %w[etudiant enseignant entreprise artiste autre]

  STUDY_LEVELS = [
    'Seconde Générale/Techno (Hors STD2A)',
    'Seconde Professionnelle',
    'Première Générale',
    'Première Techno (Hors STD2A)',
    'Première Générale (Option Arts)',
    'Première STD2A',
    'Première Professionnelle',
    'Terminale Générale (Option Arts)',
    'Terminale STD2A',
    'Terminale Générale',
    'Terminale Techno (Hors STD2A)',
    'Terminale Professionnelle',
    'BMA (Brevet des Métiers d\'Art)',
    'Classe Prépa (CPGE)',
    'DNMADE Année 1',
    'DNMADE Année 2',
    'DNMADE Année 3',
    'BTS Année 1',
    'BTS Année 2',
    'BUT Année 1',
    'BUT Année 2',
    'BUT Année 3',
    'Licence 1',
    'Licence 2',
    'Licence 3',
    'Licence Professionnelle',
    'DSAA Année 1',
    'DSAA Année 2',
    'Master 1 (Université/École)',
    'Master 2 (Université/École)',
    'Diplôme Supérieur d\'École d\'Art (Bac+5)',
    'Mastère Spécialisé (Bac+6)',
    'Doctorat',
    'Autre'
  ]

  # Validations Champs
  validates :study_level, inclusion: { in: STUDY_LEVELS, message: "n'est pas valide" }, if: -> { statut == 'etudiant' && study_level.present? }
  validates :rgpd_consent, acceptance: true
  validates :pseudo, presence: true, uniqueness: { message: I18n.t('user.pseudo_taken') }
  validates :firstname, presence: true
  validates :statut, inclusion: { in: STATUTS, message: I18n.t('user.invalid_statut', value: "%{value}") }
  validates :email, uniqueness: { case_sensitive: false }
  validate :no_ban_words_in_names

  # --- ASSOCIATIONS (Toutes nettoyées avec dependent: :destroy) ---
  
  belongs_to :etablissement, optional: true

  # Visites
  has_many :daily_visits, dependent: :destroy

  # Parrainage
  has_one :referral, foreign_key: 'referee_id', dependent: :destroy
  has_many :referrals_as_referrer, class_name: 'Referral', foreign_key: 'referrer_id', dependent: :destroy
  has_many :referrals_as_referee, class_name: 'Referral', foreign_key: 'referee_id', dependent: :destroy
  has_many :referred_users, through: :referrals_as_referrer, source: :referee

  # Contributions & Feedback
  has_many :bug_reports, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :suivis, dependent: :destroy
  
  # Listes
  has_many :lists, dependent: :destroy
  has_many :list_editors, dependent: :destroy
  has_many :editable_lists, through: :list_editors, source: :list
  has_many :list_visitors, dependent: :destroy
  has_many :visitor_lists, through: :list_visitors, source: :list

  # Créations (On ne supprime pas les œuvres si le créateur part, on met à null)
  has_many :oeuvres, dependent: :nullify
  has_many :designers, dependent: :nullify
  has_many :studios, dependent: :nullify

  # Rejets (Admin)
  has_many :rejected_oeuvres, dependent: :destroy
  has_many :rejected_designers, dependent: :destroy
  has_many :rejected_studios, dependent: :destroy

  # Système
  has_many :user_devices, dependent: :destroy
  
  has_many :notifications, dependent: :destroy 
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'admin_id', dependent: :nullify

  # Gamification
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  # Favoris (Lecture seule via listes)
  has_many :saved_oeuvres, through: :lists, source: :oeuvres
  has_many :saved_designers, through: :lists, source: :designers
  has_many :saved_studios, through: :lists, source: :studios

  # --- Méthodes ---

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first
  end

  def password_required?
    return false if provider.present?
    super
  end

  def certified?
    self.certified
  end

  def admin?
    role == 'admin'
  end

  def banned?
    banned
  end

  def full_name
    "#{firstname} #{lastname}".strip
  end

  private

  def generate_referral_code
    self.referral_code = loop do
      code = SecureRandom.alphanumeric(8)
      break code unless User.exists?(referral_code: code)
    end
  end

  def no_ban_words_in_names
    ban_words = %w[
      anal anus arse ass ballsack balls bastard bitch biatch blowjob blow job hiltler
      bollock bollok boner boob bugger bum butt buttplug clitoris cock crap cunt
      damn dick dildo dyke fag feck fellate fellatio felching fuck f u c k fudgepacker
      fudge packer flange hell homo jerk jizz knobend knob end labia lmao lmfao muff
      nigger nigga omg penis piss poop prick pube pussy queer scrotum sex shit s hit
      sh1t slut smegma spunk tit tosser turd twat vagina wank whore wtf
      enculé salope connard con putain pétasse bite chatte nichon couilles trouduc
      branleur enculeur bordel foutre nique niquer suce suceuse merde merdeux zizi teub
      pipi caca cul branlette gicler giclée éjaculer éjaculation pénétration pénétrer
      porn porno pornographie negre negro salearabe xxx
    ].map { |w| Regexp.escape(w) }

    fields = { "prénom" => firstname, "nom" => lastname, "pseudo" => pseudo }
    pattern = /\b(#{ban_words.join('|')})\b/i

    fields.each do |field_name, value|
      next if value.blank?
      if value =~ pattern
        errors.add(:base, I18n.t('user.forbidden_word', field: field_name))
      end
    end
  end
end