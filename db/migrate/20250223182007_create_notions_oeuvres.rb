class CreateNotionsOeuvres < ActiveRecord::Migration[7.1]
  def change
    create_table :notions_oeuvres do |t|
      t.references :oeuvre, null: false, foreign_key: true
      t.references :notion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
