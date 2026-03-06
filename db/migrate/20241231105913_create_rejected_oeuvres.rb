class CreateRejectedreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :rejected_references do |t|
      t.string :nom_reference
      t.date :date_reference
      t.references :user, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
