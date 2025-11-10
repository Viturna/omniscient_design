class DailyVisit < ApplicationRecord
  belongs_to :user
  validates :visited_on, presence: true
end