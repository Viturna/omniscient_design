class AddCreditPhotographeToreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :references, :credit_photographe, :string
  end
end
