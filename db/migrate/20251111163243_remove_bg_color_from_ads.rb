class RemoveBgColorFromAds < ActiveRecord::Migration[8.1]
  def change
    remove_column :ads, :bg_color, :string
  end
end