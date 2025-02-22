class RemoveNomDesignerFromDesigners < ActiveRecord::Migration[7.1]
  def change
    remove_column :designers, :nom_designer, :text
  end
end
