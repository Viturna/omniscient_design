class AddStudyLevelUpdatedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :study_level_updated_at, :datetime
  end
end
