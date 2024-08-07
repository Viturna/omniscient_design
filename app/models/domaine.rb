class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :oeuvres
end
