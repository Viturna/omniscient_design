class AddCascadeDeleteToNotifications < ActiveRecord::Migration[8.1]
  def change
    # Enlever l'ancienne clé étrangère qui bloque
    remove_foreign_key :notifications, :users

    # Ajouter la nouvelle clé étrangère avec la suppression en cascade
    add_foreign_key :notifications, :users, on_delete: :cascade
  end
end