class Oeuvre < ApplicationRecord
  extend FriendlyId
  friendly_id :nom_oeuvre, use: :slugged

  validates :nom_oeuvre, uniqueness: true
  validates :presentation_generale, presence: true, length: { minimum: 200 }

  validates :image, format: { with: /\A#{URI::regexp(['http', 'https'])}\z/, message: 'must be a valid URL' }

  belongs_to :domaine
  validates :designer_ids, presence: true

  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true

  has_many :designers_oeuvres, dependent: :destroy
  has_many :designers, through: :designers_oeuvres

  has_and_belongs_to_many :notions
  attr_accessor :rejection_reason
end
