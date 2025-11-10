class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :designers_domaines
  has_many :designers, through: :designers_domaines

  has_many :oeuvres_domaines
  has_many :oeuvres, through: :oeuvres_domaines

  has_many :studios_domaines, dependent: :destroy
  has_many :studios, through: :studios_domaines
end
