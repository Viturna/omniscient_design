class AddRejectionReasonToDesigners < ActiveRecord::Migration[7.1]
  def change
    add_column :designers, :rejection_reason, :text
  end
end
