class OeuvreStudio < ApplicationRecord
  belongs_to :oeuvre
  belongs_to :studio

  validates :oeuvre_id, uniqueness: { scope: :studio_id }
end