class DropNotionsreferences < ActiveRecord::Migration[6.0]
  def change
    drop_table :notions_references
  end
end
