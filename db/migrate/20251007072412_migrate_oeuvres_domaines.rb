class MigrateOeuvresDomaines < ActiveRecord::Migration[7.1]
  def up
    Oeuvre.reset_column_information
    Oeuvre.find_each do |oeuvre|
      if oeuvre.domaine_id.present?
        OeuvresDomaine.create!(
          oeuvre_id: oeuvre.id,
          domaine_id: oeuvre.domaine_id
        )
      end
    end
  end

  def down
    OeuvresDomaine.delete_all
  end
end
