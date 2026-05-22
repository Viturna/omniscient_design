class AddArchivedToQuizzes < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :archived, :boolean, default: false, null: false
  end
end
