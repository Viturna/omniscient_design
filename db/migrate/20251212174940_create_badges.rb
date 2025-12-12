class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :level
      t.integer :threshold

      t.timestamps
    end
  end
end
