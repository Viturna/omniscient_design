class CreateRejectedStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :rejected_studios do |t|
      t.string :nom # Nom de la colonne pour le nom du studio rejeté
      t.text :reason
      
      # Référence à l'utilisateur qui a soumis le studio
      t.references :user, foreign_key: true 

      t.timestamps
    end
  end
end