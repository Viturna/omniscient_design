class ThemeController < ApplicationController
  def update
    cookies[:theme] = { value: params[:theme], expires: 1.year.from_now }
    flash[:notice] = "Thème mis à jour avec succès."
    redirect_to(request.referrer || root_path)
  end
end
