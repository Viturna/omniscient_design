class SetDailyReferencePushDefaultToTrue < ActiveRecord::Migration[8.1]
  def up
    # 1. Change le défaut pour les futurs utilisateurs
    change_column_default :users, :daily_reference_push, from: false, to: true

    # 2. Active la notification pour tous les utilisateurs actuels
    User.update_all(daily_reference_push: true)
  end

  def down
    change_column_default :users, :daily_reference_push, from: true, to: false
    # On ne revient pas en arrière pour les données existantes pour éviter d'écraser
    # les choix volontaires des utilisateurs s'ils ont déjà rechangé.
  end
end
