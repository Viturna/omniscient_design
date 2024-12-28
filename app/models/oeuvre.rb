class Oeuvre < ApplicationRecord
  extend FriendlyId
  friendly_id :nom_oeuvre, use: :slugged

  validates :nom_oeuvre, uniqueness: true
  validates :presentation_generale, presence: true, length: { minimum: 200 }
  validates :contexte_historique, presence: true, length: { minimum: 200 }
  validates :materiaux_et_innovations_techniques, presence: true, length: { minimum: 200 }
  validates :concept_et_inspiration, presence: true, length: { minimum: 200 }
  validates :dimension_esthetique, presence: true, length: { minimum: 200 }
  validates :impact_et_message, presence: true, length: { minimum: 200 }

  validates :image, format: { with: /\A#{URI::regexp(['http', 'https'])}\z/, message: 'must be a valid URL' }
  belongs_to :domaine
  validates :designer_ids, presence: true

  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true

  has_and_belongs_to_many :designers

  attr_accessor :primary_designer_ids, :secondary_designer_ids

  after_save :assign_designers

  private

  def assign_designers
    self.designers.clear
    self.designers << Designer.where(id: primary_designer_ids) if primary_designer_ids.present?
    self.designers << Designer.where(id: secondary_designer_ids) if secondary_designer_ids.present?
  end
end
