class AddTargetRegionsToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :target_regions, :text
  end
end
