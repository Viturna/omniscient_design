class List < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  validates :name, presence: true
  has_many :list_items, dependent: :destroy
  has_many :oeuvres, through: :list_items, source: :listable, source_type: 'Oeuvre'
  has_many :designers, through: :list_items, source: :listable, source_type: 'Designer'


  before_create :generate_share_token
  has_many :list_editors
  has_many :editors, through: :list_editors, source: :user

  has_many :list_visitors
  has_many :visitors, through: :list_visitors, source: :user
  before_save :store_previous_share_token, if: :share_token_changed?
  private

  def generate_share_token
    self.share_token ||= SecureRandom.hex(10) # Génère un token aléatoire unique
  end

  def store_previous_share_token
    if share_token.nil? && previous_share_token.nil?
      self.previous_share_token = SecureRandom.hex(10)
    elsif share_token.nil?
      self.previous_share_token = share_token_was
    end
  end
end
