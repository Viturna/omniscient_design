class AddNewsletterToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :newsletter, :boolean, default: false
  end
end