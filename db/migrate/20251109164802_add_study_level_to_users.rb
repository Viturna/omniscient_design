class AddStudyLevelToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :study_level, :string
  end
end
