class Api::DailyReferencesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show], raise: false
  skip_before_action :verify_authenticity_token, only: [:show], raise: false

  def show
    daily_ref = DailyReference.for_today || DailyReference.order(date: :desc).first
    
    if daily_ref.nil?
      render json: { error: "Aucune référence du jour disponible" }, status: :not_found
      return
    end

    reference = daily_ref.reference
    image = reference.reference_images.first
    image_url = if image&.file&.attached?
      request.base_url + Rails.application.routes.url_helpers.rails_blob_path(image.file, only_path: true)
    else
      nil
    end

    render json: {
      id: reference.id,
      name: reference.nom_reference,
      designers: reference.designers.map(&:nom_designer).join(', '),
      year: reference.date_reference&.to_s,
      description: reference.presentation_generale || reference.notions.first&.definition || "",
      image_url: image_url,
      url: request.base_url + "/references/#{reference.slug}"
    }
  end
end
