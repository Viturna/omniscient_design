class AddViewsCountToEntities < ActiveRecord::Migration[8.1]
  def change
    add_column :designers, :views_count, :integer, default: 0, null: false
    add_column :studios, :views_count, :integer, default: 0, null: false
    add_column :references, :views_count, :integer, default: 0, null: false
  end
end
