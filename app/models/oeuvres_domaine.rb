class OeuvresDomaine < ApplicationRecord
  self.table_name = "oeuvres_domaines"

  belongs_to :oeuvre
  belongs_to :domaine
end
