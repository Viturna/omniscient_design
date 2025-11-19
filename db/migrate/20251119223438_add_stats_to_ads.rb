class AddStatsToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :impressions_count, :integer, default: 0
    add_column :ads, :clicks_count, :integer, default: 0
  end
end
