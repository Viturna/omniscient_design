class QuizAnswer < ApplicationRecord
  belongs_to :quiz_question
  
  validates :content, presence: true
end
