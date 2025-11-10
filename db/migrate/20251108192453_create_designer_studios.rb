class CreateDesignerStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :designer_studios do |t|
      t.references :designer, null: false, foreign_key: true
      t.references :studio, null: false, foreign_key: true
      t.integer :date_entree
      t.integer :date_sortie

      t.timestamps
    end
  end
end
