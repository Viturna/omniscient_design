class Country < ApplicationRecord
  validates :country, uniqueness: true
  has_many :designers

  def name
    country  # Remplacez 'country' par le nom de l'attribut qui contient le nom du pays dans votre modèle Country
  end
end
