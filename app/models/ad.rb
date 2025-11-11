class Ad < ApplicationRecord
  # 1. Attachements Active Storage
  has_one_attached :image
  has_one_attached :image_mobile

  # 2. Validations
  validates :title, presence: true
  validates :link, presence: true
  validates :image, attached: true, # On s'assure que l'image principale est présente
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' }
  validates :image_mobile,
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' },
            allow_blank: true # L'image mobile est optionnelle

  # 3. Scope (existant)
  scope :currently_active, -> {
    where(active: true)
      .where('start_date IS NULL OR start_date <= ?', Date.current)
      .where('end_date IS NULL OR end_date >= ?', Date.current)
  }

  # 4. Méthode de statut (existante)
  def currently_running?
    self.active &&
    (self.start_date.nil? || self.start_date <= Date.current) &&
    (self.end_date.nil? || self.end_date >= Date.current)
  end

  # 5. Déclencheur pour la conversion (après sauvegarde)
  after_commit :process_images, on: [:create, :update]

  private

  # Logique principale pour traiter les deux images
  def process_images
    # Traite l'image principale
    process_attachment(:image, "ads") if image.attached? && image.blob.saved_change_to_id?
    
    # Traite l'image mobile si elle existe
    process_attachment(:image_mobile, "ads") if image_mobile.attached? && image_mobile.blob.saved_change_to_id?
  end

  # Méthode générique pour convertir/redimensionner et stocker dans un dossier
  def process_attachment(attachment_name, folder_name)
    attachment = self.send(attachment_name)
    return if attachment.blob.content_type == "image/webp" # Déjà au bon format

    require "mini_magick"
    max_dimensions = "2000x2000>"
    compression_quality = "80"

    original_blob = attachment.blob

    original_blob.open(tmpdir: Rails.root.join("tmp")) do |file|
      img = MiniMagick::Image.new(file.path)

      img.format "webp"
      img.combine_options do |c|
        c.resize max_dimensions
        c.quality compression_quality
      end

      random_name = SecureRandom.hex(10)
      filename = "#{random_name}.webp"
      
      webp_tempfile = Tempfile.new([random_name, ".webp"], Rails.root.join("tmp"))
      img.write(webp_tempfile.path)

      # C'est ici que la magie opère :
      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: webp_tempfile,
        filename: filename,
        content_type: "image/webp",
        key: "#{folder_name}/#{filename}" # <-- Utilise le dossier "ads/"
      )

      # Attache le nouveau blob (WebP) et purge l'ancien
      attachment.attachment.update_column(:blob_id, new_blob.id)
      original_blob.purge_later
    end
  rescue => e
    Rails.logger.error("ERREUR WEBP/RESIZE pour Ad ID #{id} (#{attachment_name}): #{e.message}")
  end
end