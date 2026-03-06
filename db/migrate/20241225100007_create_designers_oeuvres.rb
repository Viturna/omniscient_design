class CreateDesignersreferences < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:designers_references)
    create_table :designers_references do |t|
      t.references :designer, null: false, foreign_key: true
      t.references :reference, null: false, foreign_key: true

      t.timestamps
      end
    end
    add_index :designers_references, [:designer_id, :reference_id], unique: true
  end
end
