class Admin::OeuvresController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def edit_verbs
    @current_page = 'oeuvres_verbs' 
    
    # 1. Base de la requête
    @oeuvres = Oeuvre.includes(:verbs).order(created_at: :desc)
    
    # 2. Si une recherche est effectuée, on filtre par nom
    if params[:search].present?
      # LOWER permet de rendre la recherche insensible aux majuscules/minuscules
      @oeuvres = @oeuvres.where("LOWER(nom_oeuvre) LIKE ?", "%#{params[:search].downcase}%")
    end
    
    # 3. On limite à 50 résultats maximum pour la performance
    @oeuvres = @oeuvres.limit(50)
  
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