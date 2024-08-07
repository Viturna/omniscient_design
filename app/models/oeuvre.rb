class Oeuvre < ApplicationRecord
  validates :nom_oeuvre, uniqueness: true
  validates :description, presence: true, length: { minimum: 200 }
  validates :image, format: { with: /\A#{URI::regexp(['http', 'https'])}\z/, message: 'must be a valid URL' }
  belongs_to :domaine
  belongs_to :designer
  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true
end
