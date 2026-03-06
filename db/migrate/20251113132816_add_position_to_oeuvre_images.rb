class AddPositionToreferenceImages < ActiveRecord::Migration[8.1]
  def change
    add_column :reference_images, :position, :integer
  end
end
