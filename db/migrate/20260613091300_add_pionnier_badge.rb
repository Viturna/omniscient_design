class AddPionnierBadge < ActiveRecord::Migration[8.1]
  def up
    badge = Badge.find_or_create_by(name: 'Pionnier') do |b|
      b.category = 'special'
      b.level = 'standard'
      b.threshold = 0
      b.description = 'Tu fais partie des 1000 premiers membres historiques.'
      b.image_name = 'early_adopter_2.png'
    end

    # Attribuer rétroactivement aux 1000 premiers utilisateurs
    User.where('id <= 1000').find_each do |user|
      UserBadge.find_or_create_by(user: user, badge: badge)
    end
  end

  def down
    badge = Badge.find_by(name: 'Pionnier')
    if badge
      UserBadge.where(badge: badge).destroy_all
      badge.destroy
    end
  end
end
