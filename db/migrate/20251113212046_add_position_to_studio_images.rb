class AddPositionToStudioImages < ActiveRecord::Migration[8.1]
  def change
    add_column :studio_images, :position, :integer
  end
end
