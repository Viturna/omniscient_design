class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :status, { unread: 0, read: 1 }
end