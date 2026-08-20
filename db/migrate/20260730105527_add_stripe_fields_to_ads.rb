class AddStripeFieldsToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :status, :string, default: 'pending'
    add_column :ads, :stripe_session_id, :string
    add_column :ads, :email, :string
    add_column :ads, :price_paid, :integer
    add_column :ads, :duration_days, :integer
  end
end
