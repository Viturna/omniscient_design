class DesignersOeuvre < ApplicationRecord
  belongs_to :designer
  belongs_to :oeuvre

  validates :designer_id, uniqueness: { scope: :oeuvre_id, message: "Ce designer est déjà associé." }
end
