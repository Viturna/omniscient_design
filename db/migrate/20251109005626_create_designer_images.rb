class CreateDesignerImages < ActiveRecord::Migration[8.1]
  def change
    create_table :designer_images do |t|
      t.references :designer, null: false, foreign_key: true
      t.string :credit

      t.timestamps
    end
  end
end
