class DesignersDomaine < ApplicationRecord
  self.table_name = "designers_domaines"

  belongs_to :designer
  belongs_to :domaine
end
