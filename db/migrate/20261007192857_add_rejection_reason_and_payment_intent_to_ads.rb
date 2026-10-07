class AddRejectionReasonAndPaymentIntentToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :rejection_reason, :text
    add_column :ads, :stripe_payment_intent_id, :string
  end
end
