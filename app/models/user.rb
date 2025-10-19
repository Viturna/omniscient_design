class User < ApplicationRecord
  before_create :generate_referral_code

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Attributs
  attribute :banned, :boolean, default: false

  # Statuts valides
  STATUTS = %w[Student Teacher Company Association Designer Artist Other Étudiant Enseignant Entreprise Artiste Autre]

  # Validations
  validates :rgpd_consent, acceptance: true
  validates :pseudo, presence: true, uniqueness: { message: I18n.t('user.pseudo_taken') }
  validates :firstname, presence: true
  validates :statut, inclusion: { in: STATUTS, message: I18n.t('user.invalid_statut', value: "%{value}") }
  validates :email, uniqueness: { case_sensitive: false }

  validate :no_ban_words_in_names

  # Associations
  belongs_to :etablissement, optional: true

  has_one :referral, foreign_key: 'referee_id'
  has_many :referrals_as_referrer, class_name: 'Referral', foreign_key: 'referrer_id'
  has_many :referrals_as_referee, class_name: 'Referral', foreign_key: 'referee_id'
  has_many :referred_users, through: :referrals_as_referrer, source: :referee

  has_many :bug_reports
  has_many :lists
  has_many :oeuvres
  has_many :designers
  has_many :notifications, dependent: :destroy

  has_many :feedbacks
  has_many :suivis, dependent: :destroy

  has_many :list_editors
  has_many :editable_lists, through: :list_editors, source: :list

  has_many :list_visitors
  has_many :visitor_lists, through: :list_visitors, source: :list

  has_many :rejected_oeuvres
  has_many :rejected_designers

  # Méthodes
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

  # Génération d’un code de parrainage unique
  def generate_referral_code
    self.referral_code = loop do
      code = SecureRandom.alphanumeric(8)
      break code unless User.exists?(referral_code: code)
    end
  end

  # Validation des noms et pseudo contre les mots interdits
  def no_ban_words_in_names
    ban_words = %w[
      anal anus arse ass ballsack balls bastard bitch biatch blowjob blow job
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
