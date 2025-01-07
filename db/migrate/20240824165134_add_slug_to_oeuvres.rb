class AddSlugToOeuvres < ActiveRecord::Migration[7.1]
  def change
    add_column :oeuvres, :slug, :string
    add_index :oeuvres, :slug, unique: true
  end
end
