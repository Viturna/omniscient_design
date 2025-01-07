class RejectedDesigner < ApplicationRecord
  belongs_to :user, optional: true
  validates :nom_designer, presence: true
end
