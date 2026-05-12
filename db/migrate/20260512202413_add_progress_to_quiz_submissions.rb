class AddProgressToQuizSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :quiz_submissions, :current_question_index, :integer
    add_column :quiz_submissions, :user_answers, :json
    add_column :quiz_submissions, :status, :string
  end
end
