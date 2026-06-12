class CreateTipClicks < ActiveRecord::Migration[8.1]
  def change
    create_table :tip_clicks do |t|
      t.timestamps
    end
  end
end
