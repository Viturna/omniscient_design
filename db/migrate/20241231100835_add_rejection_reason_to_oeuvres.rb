class AddRejectionReasonToreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :references, :rejection_reason, :text
  end
end
