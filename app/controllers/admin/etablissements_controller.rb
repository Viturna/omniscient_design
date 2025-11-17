class Admin::EtablissementsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
 before_action :set_etablissement, only: [:edit, :update, :destroy]

  def index
    # On compte les utilisateurs avec une seule requête SQL performante
    @etablissements_scope = Etablissement
                              .left_joins(:users)
                              .group('etablissements.id')
                              .select('etablissements.*, COUNT(users.id) AS users_count')
                              .order(:name)
    
    # Kaminari s'applique à la fin
    @etablissements = @etablissements_scope.page(params[:page])
  end

  def edit
    # L'action est vide, elle va juste rendre app/views/admin/etablissements/edit.html.erb
    # (Ce fichier reste à créer)
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
      # Si la suppression échoue (par ex. à cause d'une autre dépendance)
      redirect_to admin_etablissements_path, alert: "Impossible de supprimer l'établissement. Erreurs: #{@etablissement.errors.full_messages.join(', ')}"
    end
  end
  private

  def set_etablissement
    @etablissement = Etablissement.find(params[:id])
  end

  # Ajoutez les `permit` pour tous les champs que vous voulez pouvoir modifier
  def etablissement_params
    params.require(:etablissement).permit(
      :name, :address, :city, :region, :academy, :phone, 
      :website, :messagerie, :statut_public_prive, :type_etablissement
      # Ajoutez les booléens si vous les rendez éditables
      # :voie_generale, :voie_technologique, :voie_professionnelle, 
      # :post_bac, :section_arts, :section_cinema, :section_theatre
    )
  end

  def authenticate_admin!
    redirect_to root_path, alert: "Accès refusé." unless current_user&.admin?
  end
end