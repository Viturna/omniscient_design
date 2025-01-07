class CreateJoinTableDesignersDomaines < ActiveRecord::Migration[7.1]
  def change
    create_join_table :designers, :domaines do |t|
      t.index :designer_id
      t.index :domaine_id
      t.foreign_key :designers
      t.foreign_key :domaines
    end
  end
end
