class RemoveNomDesignerFromRejectedDesigners < ActiveRecord::Migration[7.1]
  def change
    remove_column :rejected_designers, :nom_designer, :string
  end
end
