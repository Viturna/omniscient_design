class AddPositionToDesignerImages < ActiveRecord::Migration[8.1]
  def change
    add_column :designer_images, :position, :integer
  end
end
