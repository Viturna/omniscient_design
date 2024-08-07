class BugReport < ApplicationRecord
  STATUSES = ['À faire', 'En cours', 'Corrigé'].freeze

  belongs_to :user

  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= 'À faire'
  end
end
