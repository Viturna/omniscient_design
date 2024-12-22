class AddCertifiedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :certified, :boolean
  end
end
