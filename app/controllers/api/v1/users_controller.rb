# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token # important pour API
  before_action :set_default_format

  def create
    user = User.find_for_authentication(email: params[:email])
    if user&.valid_password?(params[:password])
      render json: {
        user: user.slice(:id, :email, :role),
        token: user.id.to_s # ou JWT si tu veux
      }, status: :ok
    else
      render json: { error: 'Email ou mot de passe invalide' }, status: :unauthorized
    end
  end

  def show
    user = User.find_by(id: request.headers['Authorization'])
    if user
      render json: { user: user.slice(:id, :email, :role) }, status: :ok
    else
      render json: { error: 'Non connecté' }, status: :unauthorized
    end
  end

  def destroy
    head :no_content
  end

  private

  def set_default_format
    request.format = :json
  end
end
