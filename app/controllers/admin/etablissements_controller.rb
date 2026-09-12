require 'csv' # Nécessaire pour l'export

class Admin::EtablissementsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_etablissement, only: %i[edit update destroy]

  def index
    @current_page = 'etablissements'
    # 1. Requête de base : On joint les users et on prépare le comptage
    @etablissements_scope = Etablissement
                            .left_joins(:users)
                            .group('etablissements.id')
                            .select('etablissements.*, COUNT(users.id) AS users_count')

    # 2. Recherche textuelle
    if params[:query].present?
      query = "%#{params[:query]}%"
      @etablissements_scope = @etablissements_scope.where(
        "etablissements.name ILIKE :q OR
         etablissements.uai ILIKE :q OR
         etablissements.city ILIKE :q OR
         etablissements.academy ILIKE :q",
        q: query
      )
    end

    # 3. Filtre Activité / Membres
    case params[:activity]
    when 'with_users'
      @etablissements_scope = @etablissements_scope.having('COUNT(users.id) > 0')
    when 'without_users'
      @etablissements_scope = @etablissements_scope.having('COUNT(users.id) = 0')
    end

    # 4. Filtre Statut Public / Privé
    if params[:statut].present?
      @etablissements_scope = @etablissements_scope.where(statut_public_prive: params[:statut])
    end

    # 5. Filtre Type d'établissement
    if params[:type_etablissement].present?
      @etablissements_scope = @etablissements_scope.where(type_etablissement: params[:type_etablissement])
    end

    # 6. Filtre Académie
    if params[:academy].present?
      @etablissements_scope = @etablissements_scope.where(academy: params[:academy])
    end

    # 7. Filtre Section / Filière
    case params[:section]
    when 'arts'
      @etablissements_scope = @etablissements_scope.where(section_arts: true)
    when 'cinema'
      @etablissements_scope = @etablissements_scope.where(section_cinema: true)
    when 'theatre'
      @etablissements_scope = @etablissements_scope.where(section_theatre: true)
    when 'post_bac'
      @etablissements_scope = @etablissements_scope.where(post_bac: true)
    when 'pro'
      @etablissements_scope = @etablissements_scope.where(voie_professionnelle: true)
    when 'techno'
      @etablissements_scope = @etablissements_scope.where(voie_technologique: true)
    end

    # 8. Tri
    case params[:sort]
    when 'users_count_asc'
      @etablissements_scope = @etablissements_scope.order('users_count ASC, etablissements.name ASC')
    when 'name_asc'
      @etablissements_scope = @etablissements_scope.order('etablissements.name ASC')
    when 'name_desc'
      @etablissements_scope = @etablissements_scope.order('etablissements.name DESC')
    when 'city_asc'
      @etablissements_scope = @etablissements_scope.order('etablissements.city ASC, etablissements.name ASC')
    when 'academy_asc'
      @etablissements_scope = @etablissements_scope.order('etablissements.academy ASC, etablissements.name ASC')
    else # 'users_count_desc' par défaut
      @etablissements_scope = @etablissements_scope.order('users_count DESC, etablissements.name ASC')
    end

    # Listes pour les filtres dropdown
    @statuts_for_filter = Etablissement.where.not(statut_public_prive: [nil, '']).distinct.order(:statut_public_prive).pluck(:statut_public_prive)
    @types_for_filter = Etablissement.where.not(type_etablissement: [nil, '']).distinct.order(:type_etablissement).pluck(:type_etablissement)
    @academies_for_filter = Etablissement.where.not(academy: [nil, '']).distinct.order(:academy).pluck(:academy)

    # KPIs
    @total_etablissements = Etablissement.count
    @active_etablissements = Etablissement.joins(:users).distinct.count
    @total_users_linked = User.where.not(etablissement_id: nil).count

    respond_to do |format|
      format.html do
        @etablissements = @etablissements_scope.page(params[:page]).per(30)
      end

      format.csv do
        @export_etablissements = @etablissements_scope
        send_data generate_csv(@export_etablissements),
                  filename: "etablissements-#{Date.today}.csv"
      end
    end
  end

  def edit; end

  def update
    if @etablissement.update(etablissement_params)
      redirect_to admin_etablissements_path, notice: 'Établissement mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @etablissement.destroy
      redirect_to admin_etablissements_path, notice: "L'établissement '#{@etablissement.name}' a été supprimé."
    else
      redirect_to admin_etablissements_path, alert: "Impossible de supprimer l'établissement."
    end
  end

  private

  def set_etablissement
    @etablissement = Etablissement.find(params[:id])
  end

  def generate_csv(etablissements)
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # En-têtes exhaustifs
      csv << [
        'ID', 'Nom', 'Nb Utilisateurs', 'UAI', 'Ville', 'CP', 'Adresse',
        'Académie', 'Région', 'Statut', 'Type',
        'Téléphone', 'Email', 'Site Web',
        'Voie Générale', 'Voie Techno', 'Voie Pro', 'Post-Bac',
        'Section Arts', 'Section Cinéma', 'Section Théâtre',
        'Latitude', 'Longitude'
      ]

      etablissements.each do |etab|
        csv << [
          etab.id,
          etab.name,
          etab.users_count, # Le nombre de personnes (calculé dans la requête)
          etab.uai,
          etab.city,
          begin
            etab.try(:zip_code)
          rescue StandardError
            ''
          end, # Gestion erreur si colonne manquante
          etab.address,
          etab.academy,
          etab.region,
          etab.statut_public_prive,
          etab.type_etablissement,
          etab.phone,
          etab.messagerie,
          etab.website,
          etab.voie_generale ? 'Oui' : 'Non',
          etab.voie_technologique ? 'Oui' : 'Non',
          etab.voie_professionnelle ? 'Oui' : 'Non',
          etab.post_bac ? 'Oui' : 'Non',
          etab.section_arts ? 'Oui' : 'Non',
          etab.section_cinema ? 'Oui' : 'Non',
          etab.section_theatre ? 'Oui' : 'Non',
          etab.latitude,
          etab.longitude
        ]
      end
    end
  end

  def etablissement_params
    params.require(:etablissement).permit(
      :name, :uai, :city, :zip_code, :address, :academy, :region,
      :statut_public_prive, :type_etablissement, :phone, :messagerie,
      :website, :voie_generale, :voie_technologique, :voie_professionnelle,
      :post_bac, :section_arts, :section_cinema, :section_theatre,
      :latitude, :longitude
    )
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Accès refusé.' unless current_user&.admin?
  end
end
