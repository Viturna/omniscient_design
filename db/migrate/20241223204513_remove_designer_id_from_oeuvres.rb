class RemoveDesignerIdFromOeuvres < ActiveRecord::Migration[7.1]
  def change
    remove_column :oeuvres, :designer_id, :bigint
  end
end
