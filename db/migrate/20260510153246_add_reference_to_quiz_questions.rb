class AddReferenceToQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    add_reference :quiz_questions, :reference, null: true, foreign_key: true
  end
end
