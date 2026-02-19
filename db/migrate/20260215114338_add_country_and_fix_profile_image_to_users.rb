class AddCountryAndFixProfileImageToUsers < ActiveRecord::Migration[8.1]
  def change
    # 1. Ajout de la liaison avec le pays
    add_reference :users, :country, foreign_key: true

    # 2. Suppression de l'ancienne colonne string 'profile_image' 
    # car ActiveStorage gère ça via la table 'active_storage_attachments'.
    # Si on la garde, cela crée un conflit de nom.
    if column_exists?(:users, :profile_image)
      remove_column :users, :profile_image, :string
    end
  end
end