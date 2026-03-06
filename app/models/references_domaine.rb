class ReferencesDomaine < ApplicationRecord
  self.table_name = "references_domaines"

  belongs_to :reference
  belongs_to :domaine
end
