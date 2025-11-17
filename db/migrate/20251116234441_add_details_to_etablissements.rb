class AddDetailsToEtablissements < ActiveRecord::Migration[8.1]
  def change
    add_column :etablissements, :type_etablissement, :string
    add_column :etablissements, :statut_public_prive, :string
    add_column :etablissements, :voie_generale, :boolean
    add_column :etablissements, :voie_technologique, :boolean
    add_column :etablissements, :voie_professionnelle, :boolean
    add_column :etablissements, :post_bac, :boolean
    add_column :etablissements, :section_arts, :boolean
    add_column :etablissements, :section_cinema, :boolean
    add_column :etablissements, :section_theatre, :boolean
  end
end
