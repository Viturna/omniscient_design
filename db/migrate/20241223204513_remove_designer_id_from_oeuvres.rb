class RemoveDesignerIdFromreferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :references, :designer_id, :bigint
  end
end
