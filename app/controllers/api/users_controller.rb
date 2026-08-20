module Api
  class UsersController < ApplicationController
    before_action :doorkeeper_authorize!

    def me
      user = User.find(doorkeeper_token.resource_owner_id)
      render json: {
        id: user.id,
        email: user.email,
        first_name: user.firstname,
        last_name: user.lastname
      }
    end
  end
end
