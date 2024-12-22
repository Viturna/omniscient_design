class Referral < ApplicationRecord
  belongs_to :user  # This should correspond to the user who is being referred
  belongs_to :referrer, class_name: 'User'
  belongs_to :referee, class_name: 'User'
  validates :referrer_id, presence: true
  validates :referee_id, presence: true
end
