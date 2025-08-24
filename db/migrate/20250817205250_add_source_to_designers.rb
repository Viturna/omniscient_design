class AddSourceToDesigners < ActiveRecord::Migration[7.1]
  def change
    add_column :designers, :source, :text
  end
end
