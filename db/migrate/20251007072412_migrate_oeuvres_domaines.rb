class MigratereferencesDomaines < ActiveRecord::Migration[7.1]
  def up
    Reference.reset_column_information
    Reference.find_each do |reference|
      if reference.domaine_id.present?
        referencesDomaine.create!(
          reference_id: reference.id,
          domaine_id: reference.domaine_id
        )
      end
    end
  end

  def down
    referencesDomaine.delete_all
  end
end
