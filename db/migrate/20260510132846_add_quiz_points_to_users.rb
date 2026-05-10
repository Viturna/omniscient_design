class AddQuizPointsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :quiz_points, :integer, default: 0
  end
end
