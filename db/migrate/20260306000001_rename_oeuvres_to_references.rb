class RenameOeuvresToReferences < ActiveRecord::Migration[8.1]
  def change
    # Renommer les tables principales et les jointures
    rename_table :oeuvres, :references
    rename_table :oeuvre_images, :reference_images
    rename_table :oeuvre_studios, :reference_studios
    rename_table :oeuvres_domaines, :references_domaines
    rename_table :oeuvres_verbs, :references_verbs
    # ces deux lignes étaient accidentelles : il s'agit de colonnes, pas de tables
    # rename_table :date_oeuvre, :date_reference
    # rename_table :nom_oeuvre, :nom_reference
    rename_table :designers_oeuvres, :designers_references
    rename_table :lists_oeuvres, :lists_references
    rename_table :notions_oeuvres, :notions_references
    rename_table :rejected_oeuvres, :rejected_references

    # Renommer les colonnes dans les tables de jointure
    rename_column :reference_images, :oeuvre_id, :reference_id
    rename_column :reference_studios, :oeuvre_id, :reference_id
    rename_column :references_domaines, :oeuvre_id, :reference_id
    rename_column :references_verbs, :oeuvre_id, :reference_id
    rename_column :designers_references, :oeuvre_id, :reference_id
    rename_column :lists_references, :oeuvre_id, :reference_id
    rename_column :notions_references, :oeuvre_id, :reference_id
      # rejected_references n'avait pas de colonne oeuvre_id, pas besoin de renommer
  end
end
