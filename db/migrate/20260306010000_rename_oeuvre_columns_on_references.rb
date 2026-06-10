class RenameOeuvreColumnsOnReferences < ActiveRecord::Migration[8.1]
  def change
    # older table still has nom_oeuvre and date_oeuvre
    rename_column :references, :nom_oeuvre, :nom_reference if column_exists?(:references, :nom_oeuvre)
    return unless column_exists?(:references, :date_oeuvre)

    rename_column :references, :date_oeuvre, :date_reference
  end
end
