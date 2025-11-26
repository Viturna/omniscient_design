require 'googleauth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'stringio'

# Désactive la vérification SSL en dev
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

class PushNotificationService
  PROJECT_ID = "omniscientdesign-a2e94"
  SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

  def initialize(notification)
    @notification = notification
    @user = notification.user
  end

  def send
    # --- MOUCHARD 1 : DÉMARRAGE ---
    Rails.logger.info "🚀 [PushService] Démarrage pour User ID: #{@user.id} (#{@user.email})"

    tokens = @user.user_devices.pluck(:token)
    
    # --- MOUCHARD 2 : LES TOKENS ---
    Rails.logger.info "🔍 [PushService] Tokens trouvés en BDD : #{tokens.count}"
    if tokens.empty?
      Rails.logger.warn "⚠️ [PushService] ARRÊT : Aucun token trouvé pour cet utilisateur."
      return
    end

    # --- MOUCHARD 3 : L'AUTH GOOGLE ---
    Rails.logger.info "🔑 [PushService] Tentative d'authentification Google..."
    access_token = get_access_token
    
    unless access_token
      Rails.logger.error "🛑 [PushService] ARRÊT : Échec récupération Access Token."
      return
    end
    Rails.logger.info "✅ [PushService] Authentification réussie !"

    uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")

    tokens.each do |device_token|
      # --- MOUCHARD 4 : ENVOI ---
      Rails.logger.info "📨 [PushService] Envoi vers token : #{device_token.first(10)}..."
      
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
          apns: { payload: { aps: { sound: "default", badge: 1 } } },
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "default_channel",
              sound: "default",
              icon: "ic_notification",
              color: "#FFFFFF",
              default_sound: true,
              default_vibrate_timings: true
            }
          }
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = body.to_json

      response = http.request(request)
      
      # --- MOUCHARD 5 : RÉSULTAT ---
      Rails.logger.info "📬 [PushService] Réponse Google : #{response.code} - #{response.body}"

      if response.code == '200'
        Rails.logger.info "✅ [PushService] SUCCÈS TOTAL"
      elsif response.code == '404' || response.code == '410'
        Rails.logger.warn "🗑️ [PushService] Token invalide. Suppression..."
        UserDevice.find_by(token: device_token)&.destroy
      end
    end
  end

  private

  def get_access_token
    authorizer = nil

    if ENV["FIREBASE_CREDENTIALS_JSON"].present?
      Rails.logger.info "📂 [PushService] Utilisation de la variable d'environnement JSON"
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(ENV["FIREBASE_CREDENTIALS_JSON"]),
        scope: SCOPES
      )
    elsif File.exist?(Rails.root.join('config', 'firebase-credentials.json'))
      Rails.logger.info "📂 [PushService] Utilisation du fichier physique JSON"
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join('config', 'firebase-credentials.json')),
        scope: SCOPES
      )
    else
      Rails.logger.error "🔴 [PushService] CRITIQUE : Aucun fichier ni variable ENV trouvés !"
      return nil
    end

    token_data = authorizer.fetch_access_token!
    token_data['access_token']
  rescue => e
    Rails.logger.error "🔴 [PushService] Exception Auth : #{e.message}"
    nil
  end
end