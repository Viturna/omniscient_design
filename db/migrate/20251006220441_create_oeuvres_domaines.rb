class CreatereferencesDomaines < ActiveRecord::Migration[7.1]
  def change
    create_table :references_domaines, id: false do |t|
      t.bigint :reference_id, null: false
      t.bigint :domaine_id, null: false

      t.index [:reference_id, :domaine_id], unique: true
      t.index :reference_id
      t.index :domaine_id
    end

    # Optionnel : ajouter les clés étrangères pour plus de sécurité
    add_foreign_key :references_domaines, :references
    add_foreign_key :references_domaines, :domaines
  end
end
