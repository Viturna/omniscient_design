class SetupDailyVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_visits do |t|
      t.references :user, null: false, foreign_key: true
      t.date :visited_on, null: false

      t.timestamps
    end

    # On ajoute un index simple pour que les recherches soient rapides
    # Pas d'option 'unique: true' ici, car on veut autoriser plusieurs visites par jour
    add_index :daily_visits, :visited_on
  end
end