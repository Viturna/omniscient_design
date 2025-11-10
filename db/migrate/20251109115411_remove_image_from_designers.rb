class RemoveImageFromDesigners < ActiveRecord::Migration[8.1]
  def change
    remove_column :designers, :image, :text
  end
end