class List < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  has_many :list_items, dependent: :destroy
  has_many :oeuvres, through: :list_items, source: :listable, source_type: 'Oeuvre'
  has_many :designers, through: :list_items, source: :listable, source_type: 'Designer'
end
