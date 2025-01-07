class DropRejectionsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :rejections
  end

  def down
    create_table :rejections do |t|
      t.references :oeuvre, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end
  end
end
