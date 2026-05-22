class ChangeUserIdNullableInBugReports < ActiveRecord::Migration[8.1]
  def change
    change_column_null :bug_reports, :user_id, true
  end
end
