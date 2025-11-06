class AddCreditPhotographeToOeuvres < ActiveRecord::Migration[8.1]
  def change
    add_column :oeuvres, :credit_photographe, :string
  end
end
