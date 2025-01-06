class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :oeuvres

  has_many :designers_domaines
  has_many :designers, through: :designers_domaines
end
