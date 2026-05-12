class Quiz < ApplicationRecord
  belongs_to :domaine, optional: true
  belongs_to :list, optional: true
  has_many :quiz_questions, dependent: :destroy
  has_many :quiz_submissions, dependent: :destroy

  accepts_nested_attributes_for :quiz_questions, allow_destroy: true

  validates :title, presence: true
  validates :quiz_type, inclusion: { in: %w[static dynamic] }

  def completed_by?(user)
    quiz_submissions.completed.where(user: user).exists?
  end

  def in_progress_by?(user)
    quiz_submissions.in_progress.where(user: user).exists?
  end

  def best_score_for(user)
    quiz_submissions.completed.where(user: user).maximum(:score)
  end

  def current_submission_for(user)
    quiz_submissions.where(user: user).order(updated_at: :desc).first
  end
end
