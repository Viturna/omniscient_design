class RemoveOldDomainColumnsFromOeuvres < ActiveRecord::Migration[7.1]
  def change
    remove_column :oeuvres, :domaine_id, :bigint
    remove_column :oeuvres, :domaine, :text
  end
end
