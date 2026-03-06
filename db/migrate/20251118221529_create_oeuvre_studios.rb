class CreatereferenceStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :reference_studios do |t|
      # Clé étrangère vers la table 'references'
      t.references :reference, null: false, foreign_key: true
      
      # Clé étrangère vers la table 'studios'
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
    
    # Ajoute un index d'unicité sur la paire pour s'assurer qu'une liaison est unique
    add_index :reference_studios, [:reference_id, :studio_id], unique: true
  end
end