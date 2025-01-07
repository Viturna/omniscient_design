class Feedback < ApplicationRecord
  belongs_to :user

  validates :question_1, :question_2, :question_3, :question_5, :question_6, :question_7, presence: true
  validates :user, presence: true
end
