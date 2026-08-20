class EnsureAdsColumnsExist < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:ads, :status)
      add_column :ads, :status, :string, default: 'pending'
    end
    unless column_exists?(:ads, :email)
      add_column :ads, :email, :string
    end
    unless column_exists?(:ads, :price_paid)
      add_column :ads, :price_paid, :integer
    end
    unless column_exists?(:ads, :duration_days)
      add_column :ads, :duration_days, :integer
    end
  end
end
