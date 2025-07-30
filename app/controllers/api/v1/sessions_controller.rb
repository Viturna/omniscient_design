class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token # si tu utilises des requêtes API

  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      render json: { user: user.as_json(only: [:id, :email, :role]), token: user.id.to_s }, status: :ok
    else
      render json: { error: 'Email ou mot de passe invalide' }, status: :unauthorized
    end
  end

  def show
    user = User.find_by(id: request.headers['Authorization'])
    if user
      render json: { user: user.as_json(only: [:id, :email, :role]) }, status: :ok
    else
      render json: { error: 'Non connecté' }, status: :unauthorized
    end
  end

  def destroy
    # rien à faire si on ne gère pas de tokens côté serveur
    head :no_content
  end
end
