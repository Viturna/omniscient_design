class ChangeUserIdInRejectedreferences < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rejected_references, :user_id, true
  end
end
