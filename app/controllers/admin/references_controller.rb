class Admin::ReferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def edit_verbs
    @current_page = 'references_verbs' 
    
    # 1. Base de la requête
    @references = Reference.includes(:verbs).order(created_at: :desc)
    
    # 2. Si une recherche est effectuée, on filtre par nom
    if params[:search].present?
      @references = @references.where("LOWER(nom_reference) LIKE ?", "%#{params[:search].downcase}%")
    end
    
    # 3. PAGINATION (remplace le .limit(50))
    # On affiche 50 références par page
    @references = @references.page(params[:page]).per(50)
  
    @grouped_verbs = Verb.includes(:notion).group_by(&:notion)
  end

 def update_verbs
    @reference = Reference.friendly.find(params[:id])
    
    # 1. On récupère les IDs s'ils existent, sinon on retourne un tableau vide
    # Cela évite le crash "ParameterMissing" quand on désélectionne tout
    raw_verb_ids = params.dig(:reference, :verb_ids) || []
    
    # 2. On nettoie les éventuelles chaînes vides générées par le formulaire
    verb_ids = raw_verb_ids.reject(&:blank?)
    
    if @reference.update(verb_ids: verb_ids)
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