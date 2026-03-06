class UpdatereferencesTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :references, :description, :text

    add_column :references, :presentation_generale, :text
    add_column :references, :contexte_historique, :text
    add_column :references, :materiaux_et_innovations_techniques, :text
    add_column :references, :concept_et_inspiration, :text
    add_column :references, :dimension_esthetique, :text
    add_column :references, :impact_et_message, :text
  end
end
