class RemoveVerbsEntirely < ActiveRecord::Migration[8.1]
  def change
    drop_table :references_verbs if table_exists?(:references_verbs)
    drop_table :verbs if table_exists?(:verbs)
    remove_column :notions, :verbs, :text, array: true if column_exists?(:notions, :verbs)
  end
end
