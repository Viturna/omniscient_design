class RemoveCountryIdFromDesigners < ActiveRecord::Migration[7.1]
  def change
    remove_column :designers, :country_id, :bigint
  end
end
