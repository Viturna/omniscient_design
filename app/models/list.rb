class List < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user
  validates :name, presence: true

  # ListItems pour designers et oeuvres
  has_many :list_items, dependent: :destroy
  
  has_many :oeuvres, through: :list_items, source: :listable, source_type: 'Oeuvre'
  has_many :designers, through: :list_items, source: :listable, source_type: 'Designer'
  has_many :studios, through: :list_items, source: :listable, source_type: 'Studio'

  # Éditeurs et visiteurs
  has_many :list_editors, dependent: :destroy
  has_many :editors, through: :list_editors, source: :user

  has_many :list_visitors, dependent: :destroy
  has_many :visitors, through: :list_visitors, source: :user

  before_save :store_previous_share_token, if: :will_save_change_to_share_token?

  def public
    share_token.present?
  end

  def public=(value)
    is_public = ActiveRecord::Type::Boolean.new.cast(value)

    if is_public
      self.share_token ||= (previous_share_token || SecureRandom.hex(10))
    else
      self.share_token = nil
    end
  end

  private

  def store_previous_share_token
    if share_token.nil? && share_token_was.present?
      self.previous_share_token = share_token_was
    end
  end
end