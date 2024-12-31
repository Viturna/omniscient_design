class CreateRejectedDesigners < ActiveRecord::Migration[7.1]
  def change
    create_table :rejected_designers do |t|
      t.string :nom_designer
      t.references :user, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
