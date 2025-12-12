class AddImageNameToBadges < ActiveRecord::Migration[8.1]
  def change
    add_column :badges, :image_name, :string
  end
end
