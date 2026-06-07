class CreateSeasonHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :season_histories do |t|
      t.date :month
      t.jsonb :top_users

      t.timestamps
    end
  end
end
