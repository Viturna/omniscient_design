class Domaine < ApplicationRecord
  validates :domaine, uniqueness: true
  has_many :designers_domaines
  has_many :designers, through: :designers_domaines

  has_many :oeuvres_domaines, class_name: "OeuvresDomaine", foreign_key: "domaine_id", dependent: :delete_all
  has_many :oeuvres, through: :oeuvres_domaines

end
