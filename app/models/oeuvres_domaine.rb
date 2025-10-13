class OeuvresDomaine < ApplicationRecord
  self.table_name = "oeuvres_domaines"
  self.primary_key = nil

  belongs_to :oeuvre, class_name: "Oeuvre", foreign_key: "oeuvre_id"
  belongs_to :domaine, class_name: "Domaine", foreign_key: "domaine_id"
end
