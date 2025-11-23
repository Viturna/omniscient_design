class CreateUserDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :user_devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :platform

      t.timestamps
    end
  end
end
