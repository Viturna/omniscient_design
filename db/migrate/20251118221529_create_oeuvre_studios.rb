class CreateOeuvreStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :oeuvre_studios do |t|
      # Clé étrangère vers la table 'oeuvres'
      t.references :oeuvre, null: false, foreign_key: true
      
      # Clé étrangère vers la table 'studios'
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
    
    # Ajoute un index d'unicité sur la paire pour s'assurer qu'une liaison est unique
    add_index :oeuvre_studios, [:oeuvre_id, :studio_id], unique: true
  end
end