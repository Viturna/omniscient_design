class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin, optional: true
  belongs_to :notifiable, polymorphic: true
  enum status: [:unread, :read]

end
