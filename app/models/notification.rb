class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :status, { unread: 0, read: 1 }

  after_create_commit :send_push_later

  private

  def send_push_later
    # Idéalement, utilisez ActiveJob pour ne pas ralentir le serveur
    # PushNotificationJob.perform_later(self)
    
    # Version simple pour tester :
    PushNotificationService.new(self).send
  end
end