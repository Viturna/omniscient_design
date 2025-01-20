class CreateJoinTableOeuvresNotions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :oeuvres, :notions do |t|
      t.index [:oeuvre_id, :notion_id], unique: true
      t.index [:notion_id, :oeuvre_id]
    end
  end
end
