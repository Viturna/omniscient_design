class CreateRejectedOeuvres < ActiveRecord::Migration[7.1]
  def change
    create_table :rejected_oeuvres do |t|
      t.string :nom_oeuvre
      t.date :date_oeuvre
      t.references :user, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
