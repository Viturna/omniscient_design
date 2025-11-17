class AddUaiToEtablissements < ActiveRecord::Migration[8.1]
  def change
    add_column :etablissements, :uai, :string
    # C'est important pour la performance et pour éviter les doublons
    add_index :etablissements, :uai, unique: true
  end
end