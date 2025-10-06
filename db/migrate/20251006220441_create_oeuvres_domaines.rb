class CreateOeuvresDomaines < ActiveRecord::Migration[7.1]
  def change
    create_table :oeuvres_domaines, id: false do |t|
      t.bigint :oeuvre_id, null: false
      t.bigint :domaine_id, null: false

      t.index [:oeuvre_id, :domaine_id], unique: true
      t.index :oeuvre_id
      t.index :domaine_id
    end

    # Optionnel : ajouter les clés étrangères pour plus de sécurité
    add_foreign_key :oeuvres_domaines, :oeuvres
    add_foreign_key :oeuvres_domaines, :domaines
  end
end
