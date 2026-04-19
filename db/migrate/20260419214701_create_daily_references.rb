class CreateDailyReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_references do |t|
      t.references :reference, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end
    add_index :daily_references, :date, unique: true
  end
end
