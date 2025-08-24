class AddSourceToOeuvres < ActiveRecord::Migration[7.1]
  def change
    add_column :oeuvres, :source, :text
  end
end
