class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin, optional: true
  belongs_to :notifiable, polymorphic: true
puts "--- La méthode 'enum' est définie ici : #{self.method(:enum).source_location.join(':')} ---"

  enum :status, { unread: 0, read: 1 } # Utilisez la syntaxe corrigée
end