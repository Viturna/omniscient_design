class AddAdminRelanceSentToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin_relance_sent, :boolean, default: false, null: false
  end
end