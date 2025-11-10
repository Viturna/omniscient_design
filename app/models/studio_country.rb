class StudioCountry < ApplicationRecord
  belongs_to :studio
  belongs_to :country

  # Empêche d'associer deux fois le même pays au même studio
  validates :country_id, uniqueness: { scope: :studio_id, message: "est déjà associé à ce studio" }
end