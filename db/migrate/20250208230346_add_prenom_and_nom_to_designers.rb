class AddPrenomAndNomToDesigners < ActiveRecord::Migration[7.1]
  def change
    add_column :designers, :prenom, :string
    add_column :designers, :nom, :string
  end
end
