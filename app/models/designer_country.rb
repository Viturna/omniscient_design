class DesignerCountry < ApplicationRecord
  belongs_to :designer
  belongs_to :country

  validates :country_id, uniqueness: { scope: :designer_id, message: "Ce designer a déjà ce pays associé." }
end
