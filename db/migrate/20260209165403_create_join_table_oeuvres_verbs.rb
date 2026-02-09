class CreateJoinTableOeuvresVerbs < ActiveRecord::Migration[8.1]
  def change
    create_join_table :oeuvres, :verbs do |t|
      # t.index [:oeuvre_id, :verb_id]
      # t.index [:verb_id, :oeuvre_id]
    end
  end
end
