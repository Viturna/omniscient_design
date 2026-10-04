require 'net/http'
require 'uri'
require 'json'

namespace :stripe do
  desc "Créer un compte Stripe Connect v2 et générer son lien d'onboarding"
  task :create_account, [:name] => :environment do |_t, args|
    name = args[:name] || "Partenaire"

    api_key = Stripe.api_key || ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
    if api_key.blank?
      puts "❌ Clé API Stripe introuvable."
      exit 1
    end

    puts "Création du compte Stripe Connect v2 pour #{name}..."

    # 1. Création du compte v2 avec dashboard express et responsabilités
    uri = URI.parse("https://api.stripe.com/v2/core/accounts")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request["Stripe-Version"] = "2026-01-28.preview"

    request.body = {
      identity: {
        country: "FR"
      },
      dashboard: "express",
      defaults: {
        responsibilities: {
          fees_collector: "application",
          losses_collector: "application"
        }
      },
      configuration: {
        merchant: {}
      }
    }.to_json

    response = http.request(request)
    body = JSON.parse(response.body) rescue {}

    if response.code.to_i >= 200 && response.code.to_i < 300 && body["id"]
      account_id = body["id"]
      puts "✅ Compte v2 créé avec succès !"
      puts "ID du compte Stripe : #{account_id}"

      # 2. Création du lien d'onboarding via v2 account_links
      link_uri = URI.parse("https://api.stripe.com/v2/core/account_links")
      link_request = Net::HTTP::Post.new(link_uri.request_uri)
      link_request["Authorization"] = "Bearer #{api_key}"
      link_request["Content-Type"] = "application/json"
      link_request["Stripe-Version"] = "2026-01-28.preview"

      link_request.body = {
        account: account_id,
        use_case: {
          type: "account_onboarding",
          account_onboarding: {
            refresh_url: "https://omniscientdesign.fr/schools-ads",
            return_url: "https://omniscientdesign.fr/schools-ads",
            configurations: ["merchant"]
          }
        }
      }.to_json

      link_response = http.request(link_request)
      link_body = JSON.parse(link_response.body) rescue {}

      if link_body["url"]
        puts "\n🔗 Lien d'onboarding Stripe officiel (à ouvrir pour renseigner l'IBAN et finaliser le compte) :"
        puts link_body["url"]
        puts "\n"
      else
        puts "Compte créé mais erreur lors de la génération du lien : #{link_response.body}"
      end
    else
      puts "❌ Erreur Stripe v2 : #{response.body}"
    end
  end
end
