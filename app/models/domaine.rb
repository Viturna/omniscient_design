class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :designers_domaines
  has_many :designers, through: :designers_domaines
  has_and_belongs_to_many :oeuvres, join_table: :oeuvres_domaines
end
