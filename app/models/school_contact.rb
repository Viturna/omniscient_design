class SchoolContact < ApplicationRecord
  enum :status, { pending: 0, processed: 1, archived: 2 }

  validates :school_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :request_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
