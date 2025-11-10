class CreateStudiosDomaines < ActiveRecord::Migration[8.1]
  def change
    create_table :studios_domaines do |t|
      t.references :studio, null: false, foreign_key: true
      t.references :domaine, null: false, foreign_key: true

      t.timestamps
    end
  end
end
