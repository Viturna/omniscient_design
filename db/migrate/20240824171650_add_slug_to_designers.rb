class AddSlugToDesigners < ActiveRecord::Migration[7.1]
  def change
    add_column :designers, :slug, :string
    add_index :designers, :slug, unique: true
  end
end
