require 'googleauth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'stringio' # <--- NÉCESSAIRE pour lire la variable d'env comme un fichier

# Désactive la vérification SSL en dev (Fix Mac)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

class PushNotificationService
  PROJECT_ID = "omniscientdesign-a2e94"
  SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

  def initialize(notification)
    @notification = notification
    @user = notification.user
  end

  def send
    # On récupère les tokens
    tokens = @user.user_devices.pluck(:token)
    return if tokens.empty?

    # 1. RÉCUPÉRATION SÉCURISÉE DU TOKEN D'ACCÈS
    access_token = get_access_token
    
    # Si on n'a pas réussi à s'identifier (pas de fichier ni de variable ENV), on arrête
    return unless access_token

    uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")

    tokens.each do |device_token|
      body = {
        message: {
          token: device_token,
          
          # INFO GÉNÉRALE
          notification: {
            title: "Omniscient Design",
            body: @notification.message
          },
          
          # DATA
          data: {
            notifiable_id: @notification.notifiable_id.to_s,
            notifiable_type: @notification.notifiable_type
          },

          # CONFIGURATION IOS
          apns: { 
            payload: { 
              aps: { sound: "default", badge: 1 } 
            } 
          },

          # CONFIGURATION ANDROID
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "default_channel",
              sound: "default",
              icon: "ic_notification",
              color: "#FFFFFF", # Votre couleur personnalisée
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
      
      # GESTION DES RÉPONSES
      if response.code == '200'
        Rails.logger.info "✅ Push envoyé à #{device_token.first(15)}..."
      elsif response.code == '404' || response.code == '410'
        Rails.logger.warn "🗑️ Token invalide. Suppression..."
        UserDevice.find_by(token: device_token)&.destroy
      else
        Rails.logger.error "❌ Erreur FCM (#{response.code}): #{response.body}"
      end
    end
  end

  private

  # C'EST ICI QUE LA MAGIE OPÈRE (ENV vs FICHIER)
  def get_access_token
    authorizer = nil

    if ENV["FIREBASE_CREDENTIALS_JSON"].present?
      # CAS 1 : PRODUCTION (Variable d'environnement)
      # On lit la string comme si c'était un fichier
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(ENV["FIREBASE_CREDENTIALS_JSON"]),
        scope: SCOPES
      )
    elsif File.exist?(Rails.root.join('config', 'firebase-credentials.json'))
      # CAS 2 : DÉVELOPPEMENT (Fichier physique)
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join('config', 'firebase-credentials.json')),
        scope: SCOPES
      )
    else
      # CAS 3 : ERREUR DE CONFIG
      Rails.logger.error "🔴 CRITIQUE : Aucun fichier 'firebase-credentials.json' trouvé et variable 'FIREBASE_CREDENTIALS_JSON' vide."
      return nil
    end

    token_data = authorizer.fetch_access_token!
    token_data['access_token']
  rescue => e
    Rails.logger.error "🔴 Erreur Auth Google : #{e.message}"
    nil
  end
end