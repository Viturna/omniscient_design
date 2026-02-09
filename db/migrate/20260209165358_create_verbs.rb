class CreateVerbs < ActiveRecord::Migration[8.1]
  def change
    create_table :verbs do |t|
      t.string :name
      t.references :notion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
