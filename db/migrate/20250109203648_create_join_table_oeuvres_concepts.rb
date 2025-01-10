class CreateJoinTableOeuvresConcepts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :oeuvres, :concepts do |t|
      t.index [:oeuvre_id, :concept_id]
      t.index [:concept_id, :oeuvre_id]
    end
  end
end
