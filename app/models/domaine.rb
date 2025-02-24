class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :oeuvres
  searchkick word_start: [:domaine]
  has_many :designers_domaines
  has_many :designers, through: :designers_domaines
end
