class AddTitleToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :title, :string
  end
end
