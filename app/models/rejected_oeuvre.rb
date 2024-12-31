class RejectedOeuvre < ApplicationRecord
  belongs_to :user, optional: true
  validates :nom_oeuvre, presence: true
end
