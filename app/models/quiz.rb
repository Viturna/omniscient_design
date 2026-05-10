class Quiz < ApplicationRecord
  belongs_to :domaine, optional: true
  belongs_to :list, optional: true
  has_many :quiz_questions, dependent: :destroy
  has_many :quiz_submissions, dependent: :destroy

  validates :title, presence: true
  validates :quiz_type, inclusion: { in: %w[static dynamic] }

  def completed_by?(user)
    quiz_submissions.where(user: user).exists?
  end

  def best_score_for(user)
    quiz_submissions.where(user: user).maximum(:score)
  end
end
