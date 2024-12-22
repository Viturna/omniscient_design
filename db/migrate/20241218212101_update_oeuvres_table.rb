class UpdateOeuvresTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :oeuvres, :description, :text

    add_column :oeuvres, :presentation_generale, :text
    add_column :oeuvres, :contexte_historique, :text
    add_column :oeuvres, :materiaux_et_innovations_techniques, :text
    add_column :oeuvres, :concept_et_inspiration, :text
    add_column :oeuvres, :dimension_esthetique, :text
    add_column :oeuvres, :impact_et_message, :text
  end
end
