class AddPositionToOeuvreImages < ActiveRecord::Migration[8.1]
  def change
    add_column :oeuvre_images, :position, :integer
  end
end
