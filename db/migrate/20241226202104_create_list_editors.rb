class CreateListEditors < ActiveRecord::Migration[7.1]
  def change
    create_table :list_editors do |t|
      t.references :list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
