class QuizSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  
  enum :status, { in_progress: 'in_progress', completed: 'completed' }

  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
