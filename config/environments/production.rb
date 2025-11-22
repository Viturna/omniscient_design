require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # --- GESTION DES FICHIERS STATIQUES & ASSETS ---
  
  # Désactiver la compilation à la volée (CRITIQUE POUR LA PERF)
  # Si une image ou un CSS manque, ça fera une erreur 404 au lieu de faire ramer le serveur.
  config.assets.compile = false 

  # Compresser CSS et JS
  config.assets.css_compressor = :sass
  config.assets.js_compressor = :terser
  config.assets.digest = true

  # Servir les fichiers depuis public/ (nécessaire si pas de NGINX devant ou sur Heroku/Render)
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || true

  # Cache agressif pour les assets (1 an)
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}",
    "Expires" => 1.year.from_now.to_fs(:rfc822)
  }

  # --- STOCKAGE ---
  # config.active_storage.service = :local # Décommentez si vous testez en local sans MinIO
  config.active_storage.service = :minio_images

  # --- SSL & SECURITÉ ---
  config.assume_ssl = true
  config.force_ssl = true

  # Important pour l'App Mobile : désactive la vérification stricte de l'origine
  # car la WebView peut parfois envoyer des headers différents
  config.action_controller.forgery_protection_origin_check = false

  # --- LOGGING ---
  # On utilise STDOUT (standard moderne pour les logs serveurs)
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # --- DOMAINES AUTORISÉS ---
  config.hosts = [
    "omniscientdesign.fr",
    "www.omniscientdesign.fr", # Ajouté explicitement par sécurité
    /.*\.omniscientdesign\.fr/,
    # Si vous utilisez encore ngrok pour tester la prod, décommentez la ligne ci-dessous :
    # ".ngrok-free.app" 
  ]

  # --- EMAILS (Mailjet) ---
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: "omniscientdesign.fr", protocol: "https" }

  config.action_mailer.smtp_settings = {
    address: "in-v3.mailjet.com",
    port: 587,
    user_name: ENV["MAILJET_API_KEY"],
    password: ENV["MAILJET_SECRET_KEY"],
    authentication: :plain,
    enable_starttls_auto: true
  }

  # --- REDIRECTION WWW -> NON-WWW ---
  config.middleware.insert_before 0, Rack::Rewrite do
    r301 %r{.*}, 'https://omniscientdesign.fr$&', if: Proc.new { |rack_env|
      rack_env['SERVER_NAME'] =~ /^www\./
    }
  end
end