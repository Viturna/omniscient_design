# frozen_string_literal: true

# Callback sur la création d'un access token ou grant OAuth Doorkeeper
# → Attribue le badge "Artchiv'eur" si la connexion vient d'Artchiv'
Rails.application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval do
    after_commit :check_artchiveur_badge, on: :create

    private

    def check_artchiveur_badge
      user = User.find_by(id: resource_owner_id)
      return unless user

      app_name = application&.name.to_s
      GamificationService.new(user).check_artchiveur(application_name: app_name)
    end
  end

  Doorkeeper::AccessGrant.class_eval do
    after_commit :check_artchiveur_badge, on: :create

    private

    def check_artchiveur_badge
      user = User.find_by(id: resource_owner_id)
      return unless user

      app_name = application&.name.to_s
      GamificationService.new(user).check_artchiveur(application_name: app_name)
    end
  end
end
