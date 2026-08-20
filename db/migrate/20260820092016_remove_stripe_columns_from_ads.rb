class RemoveStripeColumnsFromAds < ActiveRecord::Migration[8.1]
  def change
    remove_column :ads, :stripe_payment_intent_id, :string
    remove_column :ads, :stripe_session_id, :string
  end
end
