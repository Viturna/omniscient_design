class DesignerImage < ApplicationRecord
  belongs_to :designer

  has_one_attached :file do |attachable|
    attachable.variant :thumb,
                       resize_to_fill: [400, 400],
                       format: :webp,
                       saver: { strip: true }
  end

  validates :file,
            attached: true,
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' }

  after_commit :convert_to_webp, on: %i[create update]

  private

  # === Convertit le fichier en WebP si nécessaire ===
  def convert_to_webp
    return unless file.attached?
    return unless file.blob.saved_change_to_id?
    return if file.blob.content_type == 'image/webp'

    process_image_to_webp
  end

  # === Conversion et upload dans le dossier designers/ du MinIO ===
  def process_image_to_webp
    require 'image_processing/vips'

    reload
    original_blob = file.blob

    original_blob.open(tmpdir: Rails.root.join('tmp')) do |file|
      webp_tempfile = ImageProcessing::Vips
        .source(file.path)
        .resize_to_limit(2000, 2000)
        .convert('webp')
        .saver(Q: 80, strip: true)
        .call

      # ✅ Nom aléatoire + extension webp
      random_name = SecureRandom.hex(10)
      filename = "#{random_name}.webp"

      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: webp_tempfile,
        filename: filename,
        content_type: 'image/webp',
        key: "designers/#{filename}"
      )

      file_attachment.update_column(:blob_id, new_blob.id)

      original_blob.purge_later
    end
  rescue StandardError => e
    Rails.logger.error("ERREUR WEBP/RESIZE pour DesignerImage ID #{id}: #{e.message}")
  end
end
