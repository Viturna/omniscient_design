require 'googleauth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'stringio'

class PushNotificationService
  PROJECT_ID = 'omniscientdesign-a2e94'
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

    # On pré-calcule le unread_count avant de quitter le thread principal pour éviter 
    # des requêtes DB instables dans le thread en arrière-plan.
    unread_count = @user.notifications.unread.count

    # Lancement en arrière-plan avec with_connection
    # pour garantir la connexion DB.
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          access_token = get_access_token
          next unless access_token

          uri = URI("https://fcm.googleapis.com/v1/projects/#{PROJECT_ID}/messages:send")

          # Prépare la connexion HTTP une seule fois pour tous les tokens (meilleure perf)
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            # Config SSL Dev
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

            tokens.each do |device_token|
              # Construction du payload
              title_content = @notification.title.presence || 'Omniscient Design'
              
              body = {
                message: {
                  token: device_token,
                  notification: { title: title_content, body: @notification.message },
                  data: {
                    notifiable_id: @notification.notifiable_id.to_s,
                    notifiable_type: @notification.notifiable_type.to_s,
                    notification_id: @notification.id.to_s,
                    link: full_url(@notification.link),
                    url: full_url(@notification.link),
                    click_action: full_url(@notification.link),
                    path: @notification.link.to_s,
                    target_url: full_url(@notification.link)
                  },
                  apns: {
                    payload: {
                      aps: {
                        sound: 'default',
                        badge: unread_count,
                        "mutable-content": 1,
                        link: full_url(@notification.link),
                        url: full_url(@notification.link),
                        path: @notification.link.to_s,
                        target_url: full_url(@notification.link)
                      },
                      link: full_url(@notification.link),
                      url: full_url(@notification.link),
                      path: @notification.link.to_s,
                      target_url: full_url(@notification.link)
                    }
                  },
                  android: {
                    notification: {
                      sound: 'default',
                      default_sound: true
                    }
                  },
                  webpush: { fcm_options: { link: full_url(@notification.link) } }
                }
              }

              request = Net::HTTP::Post.new(uri)
              request['Authorization'] = "Bearer #{access_token}"
              request['Content-Type'] = 'application/json'
              request.body = body.to_json

              response = http.request(request)

              # Gestion des erreurs Google (404/410 = Token invalide)
              if %w[404 410].include?(response.code)
                Rails.logger.warn '🗑️ [PushService] Token périmé détecté, suppression...'
                UserDevice.where(token: device_token).destroy_all
              elsif response.code != '200'
                Rails.logger.error "⚠️ [PushService] Erreur Google (#{response.code}) : #{response.body}"
              else
                Rails.logger.info "✅ [PushService] Notification envoyée avec succès au token #{device_token.first(10)}..."
              end
            rescue StandardError => e
              Rails.logger.error "🔴 [PushService] Crash sur token #{device_token.first(10)} : #{e.message}"
            end
          end
        rescue StandardError => e
          Rails.logger.error "🔴 [PushService] Crash dans le Thread global : #{e.message}"
        end
      end
    end
  end

  private

  def get_access_token
    authorizer = nil
    if ENV['FIREBASE_CREDENTIALS_JSON'].present?
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(ENV['FIREBASE_CREDENTIALS_JSON']),
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
  rescue StandardError => e
    Rails.logger.error "🔴 [PushService] Auth Exception : #{e.message}"
    nil
  end

  def full_url(link)
    return link if link.blank? || link.start_with?('http')

    base_url = 'https://omniscientdesign.fr'
    "#{base_url}#{link.start_with?('/') ? '' : '/'}#{link}"
  end
end
