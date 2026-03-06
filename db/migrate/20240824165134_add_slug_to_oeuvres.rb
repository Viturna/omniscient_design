class AddSlugToreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :references, :slug, :string
    add_index :references, :slug, unique: true
  end
end
