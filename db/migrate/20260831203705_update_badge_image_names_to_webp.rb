class UpdateBadgeImageNamesToWebp < ActiveRecord::Migration[8.1]
  def up
    Badge.where("image_name LIKE '%.png'").find_each do |badge|
      badge.update_column(:image_name, badge.image_name.sub(/\.png$/, '.webp'))
    end
  end

  def down
    Badge.where("image_name LIKE '%.webp'").find_each do |badge|
      badge.update_column(:image_name, badge.image_name.sub(/\.webp$/, '.png'))
    end
  end
end
