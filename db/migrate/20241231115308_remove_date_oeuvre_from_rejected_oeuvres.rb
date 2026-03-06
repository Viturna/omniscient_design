class RemoveDatereferenceFromRejectedreferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :rejected_references, :date_reference, :date
  end
end
