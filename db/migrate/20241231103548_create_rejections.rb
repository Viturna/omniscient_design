class CreateRejections < ActiveRecord::Migration[7.1]
  def change
    create_table :rejections do |t|
      t.references :oeuvre, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
