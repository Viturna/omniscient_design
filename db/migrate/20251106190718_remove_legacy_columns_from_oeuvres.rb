class RemoveLegacyColumnsFromOeuvres < ActiveRecord::Migration[8.1]
  def change
    # Retire la colonne credit_photographe
    remove_column :oeuvres, :credit_photographe, :string

    # Retire l'ancienne colonne 'image' de type texte
    # (Celle-ci n'est plus utilisée car vous utilisez Active Storage)
    remove_column :oeuvres, :image, :text
  end
end