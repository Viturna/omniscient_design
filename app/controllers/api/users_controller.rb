module Api
  class UsersController < ApplicationController
    before_action :doorkeeper_authorize!

    def me
      user = User.find(doorkeeper_token.resource_owner_id)
      
      # Vérifier et attribuer le badge Artchiv'eur si la requête provient d'Artchiv
      app_name = doorkeeper_token.application&.name.to_s
      GamificationService.new(user).check_artchiveur(application_name: app_name)

      avatar_url = user.respond_to?(:avatar) && user.avatar.attached? ? rails_blob_url(user.avatar) : nil

      render json: {
        id: user.id,
        email: user.email,
        first_name: user.firstname,
        last_name: user.lastname,
        pseudo: user.pseudo,
        profile_picture: avatar_url
      }
    end
  end
end