class ChangeDailyReferenceDefaultsToFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :daily_reference_push, from: true, to: false
    change_column_default :users, :daily_reference_email, from: true, to: false
    
    # On met également à jour les utilisateurs existants pour qu'ils soient à false par défaut
    User.update_all(daily_reference_push: false, daily_reference_email: false)
  end
end
