class AddRgpdConsentToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :rgpd_consent, :boolean
  end
end
