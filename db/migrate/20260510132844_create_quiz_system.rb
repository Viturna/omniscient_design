class CreateQuizSystem < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.text :description
      t.references :domaine, foreign_key: true
      t.references :list, foreign_key: true, null: true
      t.string :difficulty
      t.integer :estimated_time
      t.string :quiz_type, default: 'static' # 'static' or 'dynamic'
      t.timestamps
    end

    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :content
      t.integer :order
      t.string :question_type, default: 'multiple_choice'
      t.timestamps
    end

    create_table :quiz_answers do |t|
      t.references :quiz_question, null: false, foreign_key: true
      t.text :content
      t.boolean :is_correct, default: false
      t.timestamps
    end

    create_table :quiz_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.integer :score, default: 0
      t.datetime :completed_at
      t.timestamps
    end
  end
end
