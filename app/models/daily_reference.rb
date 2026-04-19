class DailyReference < ApplicationRecord
  belongs_to :reference

  validates :date, presence: true, uniqueness: true
  validates :reference_id, presence: true

  def self.for_today
    find_by(date: Date.today)
  end
end
