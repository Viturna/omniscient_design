class AddSettingsToAds < ActiveRecord::Migration[7.0]
  def change
    add_column :ads, :weight, :integer, default: 1, null: false
    
    add_column :ads, :logged_out_only, :boolean, default: false, null: false
  end
end