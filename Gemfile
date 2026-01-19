source "https://rubygems.org"

ruby '3.3.4'

gem "rails"

# Asset pipeline (pour CSS/images, pas pour JS)
gem "sprockets-rails"
gem "htmlbeautifier"

# Base
gem "pg", "~> 1.2"
gem "puma", "~> 6.4"

# Importmap + Hotwire
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# JSON API
gem "jbuilder"

gem "webrick", ">= 1.8.2"
gem "rack", ">= 3.1.18"
gem "nokogiri", ">= 1.18.8"
gem "rack-rewrite"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# Auth + policies
gem "devise", "~> 4.9"
gem "pundit"

# Divers
gem 'axlsx'
gem 'caxlsx_rails'
gem 'iso_country_codes'
gem 'dotenv-rails', groups: [:development, :test, :production]
gem 'foreman'
gem 'requestjs-rails'
gem 'ed25519', '~> 1.2'
gem 'bcrypt_pbkdf', '~> 1.0'
gem 'net-ssh', '~> 7.2'
gem 'rubyzip', '~> 2.3.0'
gem 'sass-rails'
gem 'friendly_id', '~> 5.5.0'
gem 'sitemap_generator'
gem 'whenever', require: false
gem 'ruby-vips'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'sendgrid-ruby'
gem 'responsive_image_tag'
gem 'cookies_eu'
gem 'cloudinary'
gem 'terser'
gem 'kaminari'
gem 'chartkick'
gem 'groupdate'

gem "premailer-rails", "~> 1.12"


# Secu
gem 'rack-attack'
gem 'brakeman', require: false
gem 'bundler-audit', require: false

# S3
gem 'aws-sdk-s3', require: false
gem "active_storage_validations", "~> 3.0"

# Google AUTH
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# Apple AUTH
gem 'omniauth-apple'

gem 'fcm'
gem 'googleauth'

gem 'mailjet'