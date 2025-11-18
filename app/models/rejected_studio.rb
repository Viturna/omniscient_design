class RejectedStudio < ApplicationRecord
  belongs_to :user, optional: true
  validates :nom, presence: true
end
