require 'googleauth'
require 'net/http'
require 'uri'
require 'json'

class PushNotificationService
  PROJECT_ID = "omniscientdesign-a2e94" # Votre ID projet
  SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

  def initialize(notification)
    @notification = notification
    @user = notification.user
    # Chemin vers votre fichier JSON
    @creds_path = Rails.root.join('config', 'firebase-credentials.json')
  end

  def send
    tokens = @user.user_devices.pluck(:token)
    return if tokens.empty? || !File.exist?(@creds_path)

    # 1. Obtenir un Token d'accès Google sécurisé (OAuth2)
    access_token = get_access_token
    
    # 2. Préparer l'URL d'envoi V1
    uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")

    tokens.each do |device_token|
      # 3. Construire le message
      body = {
        message: {
          token: device_token,
          notification: {
            title: "Omniscient Design",
            body: @notification.message
          },
          data: {
            notifiable_id: @notification.notifiable_id.to_s,
            notifiable_type: @notification.notifiable_type
          },
          # Configuration spécifique iOS
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1
              }
            }
          }
        }
      }

      # 4. Envoyer la requête HTTP manuellement (C'est plus sûr)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = body.to_json

      response = http.request(request)
      
      # Logs pour débugger
      if response.code == '200'
        Rails.logger.info "✅ Notification envoyée avec succès à #{device_token}"
      else
        Rails.logger.error "❌ Erreur FCM (#{response.code}): #{response.body}"
      end
    end
  end

  private

  def get_access_token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@creds_path),
      scope: SCOPES
    )
    token_data = authorizer.fetch_access_token!
    token_data['access_token']
  end
end