class CreateAds < ActiveRecord::Migration[7.0]
  def change
    create_table :ads do |t|
      t.string :title
      t.text :description
      t.string :link
      t.string :bg_color, default: "#202020" # Une couleur par défaut
      t.boolean :active, default: true       # Active par défaut à la création
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end