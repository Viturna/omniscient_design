# db/migrate/20251026110507_change_status_to_integer_in_bug_reports.rb
class ChangeStatusToIntegerInBugReports < ActiveRecord::Migration[8.1] # ou votre version
  def up
    # 1. Exécuter la conversion de type en utilisant un CASE
    # Cela convertit 'À faire' en 0, 'En cours' en 1, etc.
    execute <<-SQL
      ALTER TABLE bug_reports
      ALTER COLUMN status TYPE integer
      USING (
        CASE
          WHEN status = 'À faire' THEN 0
          WHEN status = 'En cours' THEN 1
          WHEN status = 'Corrigé' THEN 2
          ELSE 0
        END
      )
    SQL

    # 2. Appliquer la valeur par défaut (maintenant que la colonne est un entier)
    change_column_default :bug_reports, :status, 0

    # 3. Appliquer la contrainte NOT NULL
    change_column_null :bug_reports, :status, false
  end

  def down
    # 1. Reconvertir les entiers en chaînes de caractères
    execute <<-SQL
      ALTER TABLE bug_reports
      ALTER COLUMN status TYPE character varying
      USING (
        CASE
          WHEN status = 0 THEN 'À faire'
          WHEN status = 1 THEN 'En cours'
          WHEN status = 2 THEN 'Corrigé'
          ELSE 'À faire'
        END
      )
    SQL

    # 2. Retirer la valeur par défaut
    change_column_default :bug_reports, :status, nil

    # 3. Permettre les valeurs NULL (ou remettre ce que c'était avant)
    change_column_null :bug_reports, :status, true
  end
end