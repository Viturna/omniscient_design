class RemoveDateOeuvreFromRejectedOeuvres < ActiveRecord::Migration[7.1]
  def change
    remove_column :rejected_oeuvres, :date_oeuvre, :date
  end
end
