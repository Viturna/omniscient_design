json.extract! notification, :id, :user_id, :notifiable_type, :notifiable_id, :message, :status, :created_at, :updated_at
json.url notification_url(notification, format: :json)
