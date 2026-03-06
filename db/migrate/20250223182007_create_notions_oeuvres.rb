class CreateNotionsreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :notions_references, id: false do |t|
      t.references :reference, null: false, foreign_key: true
      t.references :notion, null: false, foreign_key: true
    end

    add_index :notions_references, [:reference_id, :notion_id], unique: true
    add_index :notions_references, [:notion_id, :reference_id], unique: true
  end
end
