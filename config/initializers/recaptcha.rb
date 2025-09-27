Recaptcha.configure do |config|
  config.site_key  = ENV["RECAPTCHA_SITE_KEY"] || Rails.application.credentials.dig(:recaptcha, :site_key)
  config.secret_key = ENV["RECAPTCHA_SECRET_KEY"] || Rails.application.credentials.dig(:recaptcha, :secret_key)
end
