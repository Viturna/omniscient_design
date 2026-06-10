source 'https://rubygems.org'

ruby '3.3.4'

gem 'rails'

# Asset pipeline (pour CSS/images, pas pour JS)
gem 'htmlbeautifier'
gem 'sprockets-rails'

# Base
gem 'pg', '~> 1.2'
gem 'puma', '~> 6.4'

# Importmap + Hotwire
gem 'importmap-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

# JSON API
gem 'jbuilder'

gem 'nokogiri', '>= 1.18.8'
gem 'rack', '>= 3.1.18'
gem 'rack-rewrite'
gem 'webrick', '>= 1.8.2'

gem 'bootsnap', require: false
gem 'image_processing', '~> 1.2'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'brakeman', require: false
  gem 'rails_best_practices', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

# Auth + policies
gem 'devise', '~> 4.9'
gem 'pundit'

# Divers
gem 'axlsx'
gem 'bcrypt_pbkdf', '~> 1.0'
gem 'caxlsx_rails'
gem 'chartkick'
gem 'cloudinary'
gem 'cookies_eu'
gem 'dotenv-rails', groups: %i[development test production]
gem 'ed25519', '~> 1.2'
gem 'foreman'
gem 'friendly_id', '~> 5.5.0'
gem 'groupdate'
gem 'iso_country_codes'
gem 'kaminari'
gem 'net-ssh', '~> 7.2'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'requestjs-rails'
gem 'responsive_image_tag'
gem 'ruby-vips'
gem 'rubyzip', '~> 2.3.0'
gem 'sass-rails'
gem 'sendgrid-ruby'
gem 'sitemap_generator'
gem 'terser'
gem 'whenever', require: false

gem 'premailer-rails', '~> 1.12'

# Secu
gem 'brakeman', require: false
gem 'bundler-audit', require: false
gem 'rack-attack'

# S3
gem 'active_storage_validations', '~> 3.0'
gem 'aws-sdk-s3', require: false

# Google AUTH
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# Apple AUTH
gem 'omniauth-apple'

gem 'fcm'
gem 'googleauth'

gem 'mailjet'

gem "meta-tags", "~> 2.23"
