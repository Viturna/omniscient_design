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
  attr_accessor :remove_profile_image

  before_save :purge_profile_image, if: :remove_profile_image

  has_many :feedbacks
  has_many :suivis, dependent: :destroy

  has_many :list_editors
  has_many :editable_lists, through: :list_editors, source: :list

  has_many :list_visitors
  has_many :visitor_lists, through: :list_visitors, source: :list

  has_many :referrals_as_referrer, class_name: 'Referral', foreign_key: 'referrer_id'
  has_many :referrals_as_referee, class_name: 'Referral', foreign_key: 'referee_id'
  has_many :referred_users, through: :referrals_as_referrer, source: :referee
  has_one :referral, foreign_key: 'referee_id'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :statut, inclusion: { in: STATUTS, message: "%{value} n'est pas un statut valide" }
  def profile_image_variant
    profile_image.variant(resize_to_limit: [550, 550]).processed
  end
  private

  def purge_profile_image
    profile_image.purge_later
  end
end
