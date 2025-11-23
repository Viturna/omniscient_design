require 'fcm'

class PushNotificationService
  def initialize(notification)
    @notification = notification
    @user = notification.user
    
    # NOUVELLE MÉTHODE D'INITIALISATION
    # 1. Le premier argument est nil (on n'utilise plus la clé legacy)
    # 2. Le deuxième est le chemin vers votre fichier JSON
    # 3. Le troisième est l'ID de votre projet (trouvable dans le JSON ou URL Firebase)
    
    creds_path = Rails.root.join('config', 'firebase-credentials.json')
    project_id = "omniscientdesign-a2e94" # C'est l'ID que je vois dans votre erreur précédente
    
    @fcm = FCM.new(nil, creds_path, project_id)
  end

  def send
    tokens = @user.user_devices.pluck(:token)
    return if tokens.empty?

    # LA STRUCTURE DU MESSAGE CHANGE UN PEU EN V1
    # On doit spécifier "message" > "token" (ou topic)
    
    tokens.each do |token|
      payload = {
        token: token, # On envoie un par un ou par lots en V1
        notification: {
          title: "Omniscient Design",
          body: @notification.message,
        },
        data: {
          notifiable_id: @notification.notifiable_id.to_s, # Firebase aime les strings
          notifiable_type: @notification.notifiable_type
        },
        # Configuration spécifique pour Apple (iOS)
        apns: {
          payload: {
            aps: {
              sound: "default"
            }
          }
        }
      }
      
      response = @fcm.send_v1(payload)
      Rails.logger.info "FCM Response: #{response}"
    end
  end
end