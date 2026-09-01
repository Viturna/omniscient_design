class Ad < ApplicationRecord
  # --- 0. CONSTANTES ---
  PACKS = {
    'standard' => { name: 'Pack Semaine (7 jours)', days: 7, weight: 1, price_cents: 2900 },
    'month' => { name: 'Pack Mois (30 jours)', days: 30, weight: 1, price_cents: 9900 },
    'premium' => { name: 'Pack Premium (30 jours - Affichage x3)', days: 30, weight: 3, price_cents: 14900 }
  }.freeze

  ALLOWED_CONTENT_TYPES = [
    'image/png', 'image/jpeg', 'image/webp',
    'video/mp4', 'video/webm', 'video/quicktime'
  ].freeze

  # --- 1. CONFIGURATION ---
  has_one_attached :image
  has_one_attached :image_mobile

  # --- 2. VALIDATIONS ---
  validates :title, presence: true
  validates :link, presence: true

  # Validation Visuel Desktop
  validates :image, attached: true,
                    content_type: ALLOWED_CONTENT_TYPES,
                    size: { less_than: 25.megabytes, message: 'doit faire moins de 25 Mo' }

  # Validation Visuel Mobile (Optionnelle)
  validates :image_mobile,
            content_type: ALLOWED_CONTENT_TYPES,
            size: { less_than: 25.megabytes, message: 'doit faire moins de 25 Mo' },
            allow_blank: true

  # Validation du Poids (1 par défaut)
  validates :weight, numericality: { greater_than_or_equal_to: 1 }, presence: true

  # Email validation for visitors
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  attribute :status, :string
  enum :status, {
    pending: 'pending',
    pending_validation: 'pending_validation',
    approved: 'approved',
    rejected: 'rejected',
    completed: 'completed'
  }

  # --- 3. SCOPES ---

  # Pubs actives (statut + dates)
  scope :currently_active, lambda {
    where(active: true, status: 'approved')
      .where('start_date IS NULL OR start_date <= ?', Date.current)
      .where('end_date IS NULL OR end_date >= ?', Date.current)
  }

  # Filtre intelligent selon l'utilisateur
  scope :relevant_for, lambda { |user|
    if user.present?
      # Si utilisateur connecté : on cache celles réservées aux "logged_out_only"
      where(logged_out_only: false)
    else
      # Si visiteur : on prend tout (ou tu peux mettre .all)
      all
    end
  }

  # --- 4. MÉTHODES PUBLIQUES ---

  # Helper pour vérifier si la pub tourne
  def currently_running?
    active &&
      (start_date.nil? || start_date <= Date.current) &&
      (end_date.nil? || end_date >= Date.current)
  end

  def video?
    image.attached? && image.blob.content_type.to_s.start_with?('video/')
  end

  def mobile_video?
    image_mobile.attached? && image_mobile.blob.content_type.to_s.start_with?('video/')
  end

  # ALGORITHME DE SÉLECTION PONDÉRÉE INDIVIDUELLE
  def self.pick_weighted_random(user = nil)
    candidates = currently_active.relevant_for(user)
    return nil if candidates.empty?

    total_weight = candidates.sum { |a| a.weight.to_i.positive? ? a.weight.to_i : 1 }
    return candidates.first if total_weight <= 0

    random_point = rand(1..total_weight)
    current_weight = 0

    candidates.each do |ad|
      w = ad.weight.to_i.positive? ? ad.weight.to_i : 1
      current_weight += w
      return ad if random_point <= current_weight
    end

    candidates.first
  end

  # GÉNÉRATION D'UNE FILE D'ATTENTE PONDÉRÉE
  def self.weighted_queue_for(user = nil, size = 20)
    candidates = currently_active.includes(image_attachment: :blob, image_mobile_attachment: :blob).relevant_for(user).to_a
    return [] if candidates.empty?
    return candidates if candidates.size == 1

    total_weight = candidates.sum { |a| a.weight.to_i.positive? ? a.weight.to_i : 1 }
    return candidates.shuffle if total_weight <= 0

    queue = []
    size.times do
      random_point = rand(1..total_weight)
      current_weight = 0
      chosen = candidates.first
      candidates.each do |ad|
        w = ad.weight.to_i.positive? ? ad.weight.to_i : 1
        current_weight += w
        if random_point <= current_weight
          chosen = ad
          break
        end
      end
      queue << chosen
    end
    queue
  end

  # --- 5. TRAITEMENT DES FICHIERS (CALLBACKS) ---
  after_commit :process_attachments, on: %i[create update]

  private

  def process_attachments
    process_attachment(:image, 'ads') if image.attached? && image.blob.saved_change_to_id?
    process_attachment(:image_mobile, 'ads') if image_mobile.attached? && image_mobile.blob.saved_change_to_id?
  end

  def process_attachment(attachment_name, folder_name)
    attachment = send(attachment_name)
    content_type = attachment.blob.content_type.to_s

    if content_type.start_with?('video/')
      process_video(attachment, folder_name)
    else
      process_image_to_webp(attachment, folder_name)
    end
  rescue StandardError => e
    Rails.logger.error("ERREUR TRAITEMENT pour Ad ID #{id} (#{attachment_name}): #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
  end

  def process_video(attachment, folder_name)
    original_blob = attachment.blob

    original_blob.open(tmpdir: Rails.root.join('tmp')) do |file|
      random_name = SecureRandom.hex(10)
      filename = "#{random_name}.mp4"
      output_tempfile = Tempfile.new([random_name, '.mp4'], Rails.root.join('tmp'))
      output_path = output_tempfile.path
      output_tempfile.close # Closed so ffmpeg can write cleanly

      # Compression H.264 universelle (100% compatible iOS Safari, Chrome, Firefox, Android, Desktop)
      # - scale max 800px
      # - yuv420p (obligatoire pour lecture iOS)
      # - profile main / level 3.1
      # - movflags +faststart pour démarrage instantané
      # - -an pour supprimer l'audio
      cmd = [
        'ffmpeg', '-y',
        '-i', file.path,
        '-vf', "scale='min(800,iw)':-2",
        '-c:v', 'libx264',
        '-profile:v', 'main',
        '-level', '3.1',
        '-pix_fmt', 'yuv420p',
        '-crf', '26',
        '-preset', 'fast',
        '-movflags', '+faststart',
        '-an',
        output_path
      ]

      system(*cmd)

      return unless File.exist?(output_path) && File.size(output_path).positive?

      File.open(output_path, 'rb') do |io|
        new_blob = ActiveStorage::Blob.create_and_upload!(
          io: io,
          filename: filename,
          content_type: 'video/mp4',
          key: "#{folder_name}/#{filename}"
        )

        attachment.attachment.update_column(:blob_id, new_blob.id)
        original_blob.purge_later
      end
    ensure
      output_tempfile&.unlink
    end
  end

  def process_image_to_webp(attachment, folder_name)
    # Évite de boucler si déjà WebP
    return if attachment.blob.content_type == 'image/webp'

    require 'mini_magick'
    max_dimensions = '800x800>'
    compression_quality = '80'

    original_blob = attachment.blob

    original_blob.open(tmpdir: Rails.root.join('tmp')) do |file|
      img = MiniMagick::Image.new(file.path)

      img.format 'webp'
      img.combine_options do |c|
        c.resize max_dimensions
        c.quality compression_quality
      end

      random_name = SecureRandom.hex(10)
      filename = "#{random_name}.webp"

      webp_tempfile = Tempfile.new([random_name, '.webp'], Rails.root.join('tmp'))
      img.write(webp_tempfile.path)

      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: webp_tempfile,
        filename: filename,
        content_type: 'image/webp',
        key: "#{folder_name}/#{filename}"
      )

      attachment.attachment.update_column(:blob_id, new_blob.id)
      original_blob.purge_later
    end
  end
end
