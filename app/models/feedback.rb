class Feedback < ApplicationRecord
  belongs_to :user

  validates :question_1, :question_2, :question_3, :question_4, :question_5, :question_6, :question_7, presence: true
  validates :question_8, :question_9, :question_10, :question_11, :question_12, presence: true
  validates :user, presence: true
end
