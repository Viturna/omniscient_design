class CreateDesignersOeuvres < ActiveRecord::Migration[7.1]
  def change
    create_table :designers_oeuvres do |t|
      t.references :designer, null: false, foreign_key: true
      t.references :oeuvre, null: false, foreign_key: true

      t.timestamps
    end

    # Empêcher les doublons dans la relation
    add_index :designers_oeuvres, [:designer_id, :oeuvre_id], unique: true
  end
end
