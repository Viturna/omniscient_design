class Api::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Sécurité : Si pas connecté, on ne fait rien
    return head :unauthorized unless user_signed_in?

    token = params[:token]
    platform = params[:platform] || 'ios'

    if token.blank?
      Rails.logger.warn "⚠️ [API Device] Token vide reçu"
      return head :bad_request 
    end

    # 1. NETTOYAGE : Si ce token appartenait à quelqu'un d'autre avant (ex: changement de compte), on le libère.
    UserDevice.where(token: token).where.not(user_id: current_user.id).destroy_all

    # 2. MISE À JOUR : On cherche le device, ou on le crée s'il n'existe pas
    device = current_user.user_devices.find_or_initialize_by(token: token)
    
    # 3. ACTIF : On met à jour la date (updated_at) pour savoir qu'il est actif
    device.platform = platform
    device.touch 

    if device.save
      Rails.logger.info "✅ [Device Sync] Token synchronisé pour #{current_user.email}"
      head :ok
    else
      head :unprocessable_entity
    end
  end
end