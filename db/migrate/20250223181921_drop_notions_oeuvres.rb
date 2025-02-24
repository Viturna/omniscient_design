class DropNotionsOeuvres < ActiveRecord::Migration[6.0]
  def change
    drop_table :notions_oeuvres
  end
end
