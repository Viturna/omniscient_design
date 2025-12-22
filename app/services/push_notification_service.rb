require 'googleauth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'stringio'

class PushNotificationService
  PROJECT_ID = "omniscientdesign-a2e94"
  SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

  def initialize(notification)
    @notification = notification
    @user = notification.user
  end

  def send
    return unless @user # Sécurité

    # Optimisation : on charge uniquement les tokens uniques pour éviter les doublons d'envoi
    tokens = @user.user_devices.pluck(:token).uniq

    if tokens.empty?
      Rails.logger.info "ℹ️ [PushService] Aucun device pour User #{@user.id}, arrêt."
      return
    end

    access_token = get_access_token
    return unless access_token

    uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")
    
    # Prépare la connexion HTTP une seule fois pour tous les tokens (meilleure perf)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      # Config SSL Dev
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

      tokens.each do |device_token|
        begin
          # Construction du payload (identique à votre code)
          title_content = @notification.title.presence || "Omniscient Design"
                        unread_count = @user.notifications.unread.count
          body = {
            message: {
              token: device_token,
              notification: { title: title_content, body: @notification.message },
              data: {
                notifiable_id: @notification.notifiable_id.to_s,
                notifiable_type: @notification.notifiable_type.to_s,
                notification_id: @notification.id.to_s
              },
              apns: { payload: { aps: { sound: "default", badge: unread_count } } },
              android: { notification: { sound: "default", default_sound: true } }
            }
          }

          request = Net::HTTP::Post.new(uri)
          request['Authorization'] = "Bearer #{access_token}"
          request['Content-Type'] = 'application/json'
          request.body = body.to_json

          response = http.request(request)

          # Gestion des erreurs Google (404/410 = Token invalide)
          if ['404', '410'].include?(response.code)
            Rails.logger.warn "🗑️ [PushService] Token périmé détecté, suppression..."
            UserDevice.where(token: device_token).destroy_all
          elsif response.code != '200'
            Rails.logger.error "⚠️ [PushService] Erreur Google (#{response.code}) : #{response.body}"
          end

        rescue => e
          # C'EST ICI LE SECRET DE LA DURABILITÉ :
          # Si un envoi plante, on loggue l'erreur et on passe au token suivant !
          Rails.logger.error "🔴 [PushService] Crash sur token #{device_token.first(10)} : #{e.message}"
        end
      end
    end
  end

  private

  def get_access_token
    # (Garder votre méthode existante, elle est correcte)
    # ...
    authorizer = nil
    if ENV["FIREBASE_CREDENTIALS_JSON"].present?
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(ENV["FIREBASE_CREDENTIALS_JSON"]),
        scope: SCOPES
      )
    elsif File.exist?(Rails.root.join('config', 'firebase-credentials.json'))
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(Rails.root.join('config', 'firebase-credentials.json')),
        scope: SCOPES
      )
    else
      return nil
    end
    authorizer.fetch_access_token!['access_token']
  rescue => e
    Rails.logger.error "🔴 [PushService] Auth Exception : #{e.message}"
    nil
  end
end