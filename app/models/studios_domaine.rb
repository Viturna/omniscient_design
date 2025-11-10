class StudiosDomaine < ApplicationRecord
  self.table_name = "studios_domaines"

  belongs_to :studio
  belongs_to :domaine
end