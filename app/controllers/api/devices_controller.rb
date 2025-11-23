# app/controllers/api/devices_controller.rb
class Api::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token # Important pour API simple

  def create
    return unless user_signed_in?

    # On cherche si ce device existe déjà, sinon on le crée
    device = current_user.user_devices.find_or_initialize_by(token: params[:token])
    device.platform = params[:platform]
    device.save
    
    head :ok
  end
end