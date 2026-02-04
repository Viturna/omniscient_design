require 'csv' # Nécessaire pour l'export

class Admin::EtablissementsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_etablissement, only: [:edit, :update, :destroy]

  def index
    # 1. Préparation de la requête de base (Optimisée)
    @etablissements_scope = Etablissement
                              .left_joins(:users)
                              .group('etablissements.id')
                              .select('etablissements.*, COUNT(users.id) AS users_count')
                              .order('users_count DESC, etablissements.name ASC') # Tri par nb users puis nom
    
    # 2. Filtrage par recherche
    if params[:query].present?
      query = "%#{params[:query]}%"
      @etablissements_scope = @etablissements_scope.where(
        "etablissements.name ILIKE ? OR 
         etablissements.uai ILIKE ? OR 
         etablissements.city ILIKE ? OR 
         etablissements.academy ILIKE ? OR
         CAST(etablissements.latitude AS TEXT) ILIKE ? OR
         CAST(etablissements.longitude AS TEXT) ILIKE ?",
        query, query, query, query, query, query
      )
    end

    # 3. Réponse selon le format demandé (HTML ou CSV)
    respond_to do |format|
      format.html do
        # Affichage web : on pagine
        @etablissements = @etablissements_scope.page(params[:page])
      end

      format.csv do
        # Export Excel/CSV : on prend tout le scope (filtré mais pas paginé)
        send_data generate_csv(@etablissements_scope), 
                  filename: "etablissements-#{Date.today}.csv"
      end
    end
  end

  def edit
  end

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

  # Générateur de CSV
  def generate_csv(etablissements)
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # En-têtes
      csv << [
        "ID", "Nom", "UAI", "Ville", "Académie", "Région", 
        "Nb Utilisateurs", "Statut", "Type", 
        "Téléphone", "Email", "Site Web",
        "Générale", "Techno", "Pro", "Post-Bac",
        "Arts", "Cinéma", "Théâtre"
      ]

      # Données
      etablissements.each do |etab|
        csv << [
          etab.id,
          etab.name,
          etab.uai,
          etab.city,
          etab.academy,
          etab.region,
          etab.users_count, # Attribut virtuel calculé dans l'index
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
          etab.section_theatre ? 'Oui' : 'Non'
        ]
      end
    end
  end

  def etablissement_params
    params.require(:etablissement).permit(
      :name, :address, :city, :region, :academy, :phone, 
      :website, :messagerie, :statut_public_prive, :type_etablissement,
      :latitude, :longitude,
      :voie_generale, :voie_technologique, :voie_professionnelle, 
      :post_bac, :section_arts, :section_cinema, :section_theatre,
      :uai  
    )
  end

  def authenticate_admin!
    redirect_to root_path, alert: "Accès refusé." unless current_user&.admin?
  end
end