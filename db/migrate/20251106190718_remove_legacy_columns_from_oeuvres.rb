class RemoveLegacyColumnsFromreferences < ActiveRecord::Migration[8.1]
  def change
    # Retire la colonne credit_photographe
    remove_column :references, :credit_photographe, :string

    # Retire l'ancienne colonne 'image' de type texte
    remove_column :references, :image, :text
  end
end
