class Oeuvre < ApplicationRecord
  extend FriendlyId
  friendly_id :nom_oeuvre, use: :slugged

  searchkick word_start: [:nom_oeuvre]
  after_commit :reindex_searchkick, if: :validated?
  after_destroy :remove_from_searchkick
  
  validates :nom_oeuvre, uniqueness: true, presence: true

  belongs_to :domaine

  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true

  has_many :designers_oeuvres, dependent: :destroy
  has_many :designers, through: :designers_oeuvres

  has_many :notions_oeuvres, class_name: 'NotionsOeuvre', dependent: :destroy
  has_many :notions, through: :notions_oeuvres
  attr_accessor :rejection_reason

  def validated?
    validation == true
  end
  def image_variant
    return unless image.attached? && image.content_type&.start_with?('image/')

    image.variant(resize_to_limit: [500, 500]).processed
  rescue ActiveStorage::InvariableError
    nil
  end

  private

  def reindex_searchkick
    reindex
  end
  def remove_from_searchkick
    self.class.search_index.remove(self)
  end
end
