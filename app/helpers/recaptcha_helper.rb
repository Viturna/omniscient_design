require 'net/http'
require 'json'

module RecaptchaHelper
  def verify_recaptcha(token)
    secret_key = Rails.application.secrets.recaptcha_secret_key
    uri = URI("https://www.google.com/recaptcha/api/siteverify")
    response = Net::HTTP.post_form(uri, {
      secret: secret_key,
      response: token
    })
    json = JSON.parse(response.body)
    json["success"] && json["score"] > 0.5 # Ajustez le score selon vos besoins
  end
end
