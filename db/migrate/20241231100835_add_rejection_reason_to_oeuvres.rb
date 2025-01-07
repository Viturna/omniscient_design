class AddRejectionReasonToOeuvres < ActiveRecord::Migration[7.1]
  def change
    add_column :oeuvres, :rejection_reason, :text
  end
end
