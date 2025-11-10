class CreateStudioCountries < ActiveRecord::Migration[7.1]
  def change
    create_table :studio_countries do |t|
      t.references :studio, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
    add_index :studio_countries, [:studio_id, :country_id], unique: true
  end
end