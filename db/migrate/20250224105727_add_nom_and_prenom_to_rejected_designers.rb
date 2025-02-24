class AddNomAndPrenomToRejectedDesigners < ActiveRecord::Migration[7.1]
  def change
    add_column :rejected_designers, :nom, :string
    add_column :rejected_designers, :prenom, :string
  end
end
