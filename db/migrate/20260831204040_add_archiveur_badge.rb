class AddArchiveurBadge < ActiveRecord::Migration[8.1]
  def up
    Badge.find_or_create_by!(name: "Artchiv'eur") do |b|
      b.category = 'special'
      b.level = 'standard'
      b.description = "Ton compte Omniscient Design est connecté à Artchiv'."
      b.image_name = 'archiveur.webp'
    end
  end

  def down
    Badge.find_by(name: "Artchiv'eur")&.destroy
  end
end
