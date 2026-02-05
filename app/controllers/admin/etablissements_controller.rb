require 'csv' # Nécessaire pour l'export

class Admin::EtablissementsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_etablissement, only: [:edit, :update, :destroy]

  def index
    # 1. Requête de base : On joint les users et on prépare le comptage
    @etablissements_scope = Etablissement
                              .left_joins(:users)
                              .group('etablissements.id')
                              .select('etablissements.*, COUNT(users.id) AS users_count')
                              .order('users_count DESC, etablissements.name ASC')
    
    # 2. Recherche (si applicable)
    if params[:query].present?
      query = "%#{params[:query]}%"
      @etablissements_scope = @etablissements_scope.where(
        "etablissements.name ILIKE ? OR 
         etablissements.uai ILIKE ? OR 
         etablissements.city ILIKE ? OR 
         etablissements.academy ILIKE ?",
        query, query, query, query
      )
    end

    respond_to do |format|
      format.html do
        # Affichage HTML : On affiche tout, avec pagination
        @etablissements = @etablissements_scope.page(params[:page])
      end

      format.csv do
        # Export CSV : FILTRE SPÉCIFIQUE -> Uniquement ceux avec au moins 1 user
        @export_etablissements = @etablissements_scope.having('COUNT(users.id) > 0')
        
        send_data generate_csv(@export_etablissements), 
                  filename: "etablissements_actifs-#{Date.today}.csv"
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

  def generate_csv(etablissements)
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # En-têtes exhaustifs
      csv << [
        "ID", "Nom", "Nb Utilisateurs", "UAI", "Ville", "CP", "Adresse", 
        "Académie", "Région", "Statut", "Type", 
        "Téléphone", "Email", "Site Web",
        "Voie Générale", "Voie Techno", "Voie Pro", "Post-Bac",
        "Section Arts", "Section Cinéma", "Section Théâtre",
        "Latitude", "Longitude"
      ]

      etablissements.each do |etab|
        csv << [
          etab.id,
          etab.name,
          etab.users_count, # Le nombre de personnes (calculé dans la requête)
          etab.uai,
          etab.city,
          (etab.try(:zip_code) rescue ""), # Gestion erreur si colonne manquante
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
    params.require(:etablissement).permit! # Permet tout pour simplifier ici
  end

  def authenticate_admin!
    redirect_to root_path, alert: "Accès refusé." unless current_user&.admin?
  end
end