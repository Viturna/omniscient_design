class AddPaymentIntentToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :stripe_payment_intent_id, :string
  end
end
