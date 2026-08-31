# frozen_string_literal: true

# Callback sur la création d'un access token OAuth Doorkeeper
# → Attribue le badge "Artchiv'eur" si la connexion vient d'Artchiv'
Rails.application.config.after_initialize do
  Doorkeeper::AccessToken.class_eval do
    after_create :check_artchiveur_badge

    private

    def check_artchiveur_badge
      user = User.find_by(id: resource_owner_id)
      return unless user

      app_name = application&.name.to_s
      GamificationService.new(user).check_artchiveur(application_name: app_name)
    end
  end
end
