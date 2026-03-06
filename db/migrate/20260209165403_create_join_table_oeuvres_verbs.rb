class CreateJoinTablereferencesVerbs < ActiveRecord::Migration[8.1]
  def change
    create_join_table :references, :verbs do |t|
      # t.index [:reference_id, :verb_id]
      # t.index [:verb_id, :reference_id]
    end
  end
end
