class UpdateDesignersTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :designers, :description, :text

    add_column :designers, :presentation_generale, :text
    add_column :designers, :formation_et_influences, :text
    add_column :designers, :style_ou_philosophie, :text
    add_column :designers, :creations_majeures, :text
    add_column :designers, :heritage_et_impact, :text
  end
end
