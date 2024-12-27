class AddPreviousShareTokenToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :previous_share_token, :string
  end
end
