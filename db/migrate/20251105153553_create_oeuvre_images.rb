class CreatereferenceImages < ActiveRecord::Migration[8.1]
  def change
    create_table :reference_images do |t|
      t.belongs_to :reference, null: false, foreign_key: true
      t.string :credit

      t.timestamps
    end
  end
end
