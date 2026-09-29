class CreateSchoolContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :school_contacts do |t|
      t.string :school_name, null: false
      t.string :email, null: false
      t.text :message
      t.string :request_type, default: 'contact', null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
