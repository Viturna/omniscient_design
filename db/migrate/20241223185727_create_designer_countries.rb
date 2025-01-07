class CreateDesignerCountries < ActiveRecord::Migration[7.1]
  def change
    create_table :designer_countries do |t|
      t.references :designer, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
