class AddShareTokenToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :share_token, :string
    add_index :lists, :share_token, unique: true
  end
end
