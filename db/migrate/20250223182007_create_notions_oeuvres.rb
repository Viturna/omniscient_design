class CreateNotionsOeuvres < ActiveRecord::Migration[7.1]
  def change
    create_table :notions_oeuvres, id: false do |t|
      t.references :oeuvre, null: false, foreign_key: true
      t.references :notion, null: false, foreign_key: true
    end

    add_index :notions_oeuvres, [:oeuvre_id, :notion_id], unique: true
    add_index :notions_oeuvres, [:notion_id, :oeuvre_id], unique: true
  end
end
