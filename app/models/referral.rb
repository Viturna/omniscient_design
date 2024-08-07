class Referral < ApplicationRecord
   belongs_to :referrer, class_name: 'User'
  belongs_to :referee, class_name: 'User'
end
