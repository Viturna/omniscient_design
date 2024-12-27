class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User'
  belongs_to :referee, class_name: 'User'

  validates :referrer, presence: true
  validates :referee, presence: true
  validate :referrer_cannot_be_referee

  private

  def referrer_cannot_be_referee
    if referrer == referee
      errors.add(:referrer, "ne peut pas être le même que le filleul.")
    end
  end
end
