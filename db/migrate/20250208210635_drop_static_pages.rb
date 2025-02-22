class DropStaticPages < ActiveRecord::Migration[7.1]
  def up
    drop_table :static_pages
  end

  def down
    create_table :static_pages do |t|
      t.string :presentation
      t.timestamps
    end
  end
end
