require 'googleauth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

# Désactive la vérification SSL en dev (Fix Mac)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

class PushNotificationService
  PROJECT_ID = "omniscientdesign-a2e94"
  SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

  def initialize(notification)
    @notification = notification
    @user = notification.user
    @creds_path = Rails.root.join('config', 'firebase-credentials.json')
  end

  def send
    tokens = @user.user_devices.pluck(:token)
    return if tokens.empty? || !File.exist?(@creds_path)

    access_token = get_access_token
    uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")

    tokens.each do |device_token|
      body = {
        message: {
          token: device_token,
          
          # 1. INFO GÉNÉRALE (Titre/Corps)
          notification: {
            title: "Omniscient Design",
            body: @notification.message
          },
          
          # 2. DATA (Pour le clic)
          data: {
            notifiable_id: @notification.notifiable_id.to_s,
            notifiable_type: @notification.notifiable_type
          },

          # 3. CONFIGURATION IOS (Badge + Son)
          apns: { 
            payload: { 
              aps: { sound: "default", badge: 1 } 
            } 
          },

          # 4. CONFIGURATION ANDROID (C'est ce qu'il manquait !) 🤖
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "default_channel", # Le même ID que dans votre MainActivity.kt
              sound: "default",
              icon: "ic_notification", # Le nom du fichier sans l'extension
              color: "#FFFFFF",
              default_sound: true,
              default_vibrate_timings: true
            }
          }
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      # Désactive SSL strict pour éviter l'erreur Mac en local
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = body.to_json

      response = http.request(request)
      
      if response.code == '200'
        Rails.logger.info "✅ Notification envoyée avec succès à #{device_token.first(15)}..."
      elsif response.code == '404' || response.code == '410'
        Rails.logger.warn "🗑️ Token invalide (404). Suppression du device..."
        UserDevice.find_by(token: device_token)&.destroy
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