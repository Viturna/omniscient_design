class CreateStudioImages < ActiveRecord::Migration[7.1]
  def change
    create_table :studio_images do |t|
      t.references :studio, null: false, foreign_key: true
      t.string :credit

      t.timestamps
    end
  end
end