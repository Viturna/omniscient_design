class ChangeUserIdInRejectedDesigners < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rejected_designers, :user_id, true
  end
end
