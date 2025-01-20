class Notion < ApplicationRecord
  has_and_belongs_to_many :oeuvres
  validates :name, presence: true, uniqueness: true
end
