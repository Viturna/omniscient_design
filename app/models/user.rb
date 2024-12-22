class User < ApplicationRecord
  before_create :generate_referral_code
  validates :rgpd_consent, acceptance: true
  validates :pseudo, presence: true
  attribute :banned, :boolean, default: false

  def certified?
    self.certified
  end

  def admin?
    role == 'admin'
  end
  def banned?
    banned
  end
  def generate_referral_code
    self.referral_code = loop do
      code = SecureRandom.alphanumeric(8)
      break code unless User.exists?(referral_code: code)
    end
  end
  STATUTS = ["Étudiant", "Enseignant", "Autre"]

  has_one :referral, foreign_key: :referrer_id
  has_many :referees, through: :referrals, source: :referee
  has_many :bug_reports
  has_many :lists
  has_many :oeuvres
  has_many :designers
  has_many :notifications
  belongs_to :etablissement, optional: true
  has_one_attached :profile_image
  has_many :feedbacks
  has_many :suivis, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :statut, inclusion: { in: STATUTS, message: "%{value} n'est pas un statut valide" }

  def referred_users
    User.joins("INNER JOIN referrals ON referrals.referee_id = users.id")
        .where("referrals.referrer_id = ?", id)
  end
end
