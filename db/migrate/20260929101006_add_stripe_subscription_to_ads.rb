class AddStripeSubscriptionToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :stripe_subscription_id, :string
    add_column :ads, :stripe_customer_id, :string
    add_column :ads, :subscription_status, :string
  end
end
