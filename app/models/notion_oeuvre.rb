class NotionOeuvre < ApplicationRecord
  self.table_name = 'notions_oeuvres'  # Table de jointure

  belongs_to :oeuvre
  belongs_to :notion
end
