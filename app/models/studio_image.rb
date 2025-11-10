class StudioImage < ApplicationRecord
  belongs_to :studio

  has_one_attached :file do |attachable|
    attachable.variant :thumb,
      resize_to_fill: [400, 400],
      format: :webp
  end

  validates :file,
            attached: true,
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' }

  after_commit :convert_to_webp, on: [:create, :update]

  private

  # === Convertit le fichier en WebP si nécessaire ===
  def convert_to_webp
    return unless file.attached?
    return unless file.blob.saved_change_to_id?
    return if file.blob.content_type == "image/webp"

    process_image_to_webp
  end

  # === Conversion et upload dans le dossier studios/ du MinIO ===
  def process_image_to_webp
    require "mini_magick"

    max_dimensions = "2000x2000>"
    compression_quality = "80"

    self.reload
    original_blob = self.file.blob

    original_blob.open(tmpdir: Rails.root.join("tmp")) do |file|
      img = MiniMagick::Image.new(file.path)

      img.format "webp"
      img.combine_options do |c|
        c.resize max_dimensions
        c.quality compression_quality
      end

      # ✅ Nom aléatoire + extension webp
      random_name = SecureRandom.hex(10)
      filename = "#{random_name}.webp"

      # ✅ Création du fichier temporaire
      webp_tempfile = Tempfile.new([random_name, ".webp"], Rails.root.join("tmp"))
      img.write(webp_tempfile.path)

      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: webp_tempfile,
        filename: filename,
        content_type: "image/webp",
        key: "studios/#{filename}" # Stockage dans le dossier "studios/"
      )

      self.file_attachment.update_column(:blob_id, new_blob.id)

      original_blob.purge_later
    end
  rescue => e
    Rails.logger.error("ERREUR WEBP/RESIZE pour StudioImage ID #{id}: #{e.message}")
  end
end