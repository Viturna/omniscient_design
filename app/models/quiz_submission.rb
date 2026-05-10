class QuizSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  
  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
