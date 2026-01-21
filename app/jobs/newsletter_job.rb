require 'net/http'
require 'uri'
require 'json'

class NewsletterJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    api_key = ENV['MAILJET_API_KEY']
    secret_key = ENV['MAILJET_SECRET_KEY']
    list_id = 10603571

    return unless api_key && secret_key

    action = user.newsletter? ? "addforce" : "unsub"

    # Préparation des données
    prenom = user.firstname.presence || user.pseudo
    nom = user.lastname.presence || ""

    uri = URI.parse("https://api.mailjet.com/v3/REST/contactslist/#{list_id}/managecontact")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(api_key, secret_key)
    request.content_type = "application/json"
    
    request.body = JSON.dump({
      "Action" => action, 
      "Email" => user.email,
      "Properties" => {
        "prenom" => prenom,
        "nom" => nom
      }
    })

    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code.to_i >= 200 && response.code.to_i < 300
      status_msg = user.newsletter? ? "abonné" : "désabonné"
      Rails.logger.info "✅ [Mailjet] #{user.email} a été #{status_msg} avec succès."
    else
      Rails.logger.error "❌ [Mailjet] Erreur maj #{user.email} : #{response.body}"
    end
  end
end