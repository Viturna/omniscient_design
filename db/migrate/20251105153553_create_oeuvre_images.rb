class CreateOeuvreImages < ActiveRecord::Migration[8.1]
  def change
    create_table :oeuvre_images do |t|
      t.belongs_to :oeuvre, null: false, foreign_key: true
      t.string :credit

      t.timestamps
    end
  end
end
