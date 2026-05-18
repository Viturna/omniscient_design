class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User'
  belongs_to :referee, class_name: 'User'

  validates :referrer, presence: true
  validates :referee, presence: true
  validate :referrer_cannot_be_referee

  after_create :check_referrer_badge
  after_create :send_notification_to_referrer

  private

  def referrer_cannot_be_referee
    if referrer == referee
      errors.add(:referrer, "ne peut pas être le même que le filleul.")
    end
  end

  def check_referrer_badge
    GamificationService.new(referrer).check_ambassador
  end

  def send_notification_to_referrer
    Notification.create(
      user: referrer,
      notifiable: self,
      title: "Nouveau.elle filleul.e !",
      message: "#{referee&.pseudo || 'Un.e utilisateur.rice'} a utilisé ton code de parrainage. Merci pour ton soutien !",
      link: "/parrainage",
      status: :unread
    )
  end
end
