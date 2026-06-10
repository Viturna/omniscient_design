class Admin::ReferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def edit_notions
    @current_page = 'references_notions'

    # 1. Base de la requête
    @references = Reference.includes(:notions).order(created_at: :desc)

    # 2. Si une recherche est effectuée, on filtre par nom ou par notion
    if params[:search].present?
      query = "%#{params[:search].downcase}%"
      @references = @references.left_joins(:notions)
                               .where('LOWER(references.nom_reference) LIKE ? OR LOWER(notions.name) LIKE ?', query, query)
                               .distinct
    end

    # 3. PAGINATION (remplace le .limit(50))
    # On affiche 50 références par page
    @references = @references.page(params[:page]).per(50)

    @grouped_notions = Notion.all.group_by(&:theme)
  end

  def update_notions
    @reference = Reference.friendly.find(params[:id])

    # 1. On récupère les IDs s'ils existent, sinon on retourne un tableau vide
    # Cela évite le crash "ParameterMissing" quand on désélectionne tout
    raw_notion_ids = params.dig(:reference, :notion_ids) || []

    # 2. On nettoie les éventuelles chaînes vides générées par le formulaire
    notion_ids = raw_notion_ids.reject(&:blank?)

    if @reference.update(notion_ids: notion_ids)
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_admin!
    redirect_to root_path, alert: 'Accès interdit.' unless current_user&.admin?
  end
end
