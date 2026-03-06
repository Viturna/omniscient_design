class RejectedReference < ApplicationRecord
  belongs_to :user, optional: true
  validates :nom_reference, presence: true
end
