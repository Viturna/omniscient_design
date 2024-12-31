class ChangeUserIdInRejectedOeuvres < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rejected_oeuvres, :user_id, true
  end
end
