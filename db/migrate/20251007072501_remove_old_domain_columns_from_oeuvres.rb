class RemoveOldDomainColumnsFromreferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :references, :domaine_id, :bigint
    remove_column :references, :domaine, :text
  end
end
