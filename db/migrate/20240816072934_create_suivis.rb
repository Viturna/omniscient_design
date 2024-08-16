class CreateSuivis < ActiveRecord::Migration[7.1]
  def change
    create_table :suivis do |t|
      t.references :user, foreign_key: true, null: false # Clé étrangère vers les utilisateurs
      t.integer :nb_references_emises, default: 0, null: false
      t.integer :nb_references_validees, default: 0, null: false
      t.integer :nb_references_refusees, default: 0, null: false

      t.timestamps
    end
  end
end
