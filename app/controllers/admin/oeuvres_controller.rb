class Admin::OeuvresController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def edit_verbs
    @current_page = 'oeuvres_verbs' 
    @oeuvres = Oeuvre.includes(:verbs).order(created_at: :desc)
  
    @grouped_verbs = Verb.includes(:notion).group_by(&:notion)
  end

  def update_verbs
    @oeuvre = Oeuvre.friendly.find(params[:id])
    
    verb_ids = params.require(:oeuvre).permit(verb_ids: [])[:verb_ids].reject(&:blank?)
    
    if @oeuvre.update(verb_ids: verb_ids)
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_admin!
    redirect_to root_path, alert: "Accès interdit." unless current_user&.admin?
  end
end