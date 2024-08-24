class AddSlugToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :slug, :string
    add_index :lists, :slug, unique: true
  end
end
