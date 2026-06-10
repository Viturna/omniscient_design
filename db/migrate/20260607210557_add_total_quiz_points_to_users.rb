class AddTotalQuizPointsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :total_quiz_points, :integer, default: 0

    reversible do |dir|
      dir.up do
        User.update_all('total_quiz_points = COALESCE(quiz_points, 0)')
      end
    end
  end
end
