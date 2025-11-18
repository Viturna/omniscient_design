# db/migrate/..._add_admin_to_notifications.rb
class AddAdminToNotifications < ActiveRecord::Migration[8.1] # ou la version actuelle
  def change
    add_reference :notifications, :admin, foreign_key: { to_table: :users }
  end
end