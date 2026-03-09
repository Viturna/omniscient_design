class RenameNomOeuvreInRejectedReferences < ActiveRecord::Migration[8.1]
  def change
    rename_column :rejected_references, :nom_oeuvre, :nom_reference
  end
end