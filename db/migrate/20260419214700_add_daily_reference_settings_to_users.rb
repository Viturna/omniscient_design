class AddDailyReferenceSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :daily_reference_push, :boolean, default: true
    add_column :users, :daily_reference_email, :boolean, default: true
  end
end
