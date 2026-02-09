class AddDetailsToNotions < ActiveRecord::Migration[8.1]
  def change
    add_column :notions, :theme, :string
    # On précise array: true et une valeur par défaut vide
    add_column :notions, :verbs, :text, array: true, default: []
    
    # On ajoute un index sur le thème pour filtrer rapidement plus tard
    add_index :notions, :theme
  end
end