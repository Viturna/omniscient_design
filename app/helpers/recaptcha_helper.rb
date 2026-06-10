require 'net/http'
require 'json'
require 'openssl'

module RecaptchaHelper
  def verify_recaptcha(token)
    secret_key = ENV['RECAPTCHA_SECRET_KEY']
    uri = URI('https://www.google.com/recaptcha/api/siteverify')

    # 🔧 Création d’un client HTTP avec gestion SSL explicite
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # 🧩 En développement, on désactive la vérification SSL (utile si certificat manquant)
    http.verify_mode = if Rails.env.development?
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end

    # 🔐 Requête POST vers l’API reCAPTCHA
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data({
                            secret: secret_key,
                            response: token
                          })

    response = http.request(request)
    json = JSON.parse(response.body)

    # 🪵 Log clair pour debug
    Rails.logger.info "reCAPTCHA response: #{json.inspect}"

    # ✅ Retourne vrai si succès et score au-dessus du seuil (modifiable)
    json['success'] && (json['score'].to_f > 0.5)
  rescue StandardError => e
    Rails.logger.error "Erreur lors de la vérification reCAPTCHA: #{e.message}"
    false
  end
end
