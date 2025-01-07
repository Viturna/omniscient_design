class CreateDesignersOeuvres < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:designers_oeuvres)
    create_table :designers_oeuvres do |t|
      t.references :designer, null: false, foreign_key: true
      t.references :oeuvre, null: false, foreign_key: true

      t.timestamps
      end
    end
    add_index :designers_oeuvres, [:designer_id, :oeuvre_id], unique: true
  end
end
