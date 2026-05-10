class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  belongs_to :reference, optional: true
  has_many :quiz_answers, dependent: :destroy
  
  validates :content, presence: true

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true
end
