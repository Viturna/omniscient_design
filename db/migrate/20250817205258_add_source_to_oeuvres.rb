class AddSourceToreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :references, :source, :text
  end
end
