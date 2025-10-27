class AddHowDidYouHearToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :how_did_you_hear, :string
  end
end
