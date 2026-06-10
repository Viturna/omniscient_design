class AddMissingIndexesFromRbp < ActiveRecord::Migration[8.1]
  def change
    add_index :designers, :validated_by_user_id unless index_exists?(:designers, :validated_by_user_id)
    add_index :references, :validated_by_user_id unless index_exists?(:references, :validated_by_user_id)
    add_index :referrals, :referee_id unless index_exists?(:referrals, :referee_id)
    add_index :referrals, :referrer_id unless index_exists?(:referrals, :referrer_id)
    add_index :users, :etablissement_id unless index_exists?(:users, :etablissement_id)
  end
end
