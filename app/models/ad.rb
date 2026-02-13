class Ad < ApplicationRecord
  # --- 1. CONFIGURATION ---
  has_one_attached :image
  has_one_attached :image_mobile

  # --- 2. VALIDATIONS ---
  validates :title, presence: true
  validates :link, presence: true
  
  # Validation Image Desktop
  validates :image, attached: true, 
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' }
  
  # Validation Image Mobile (Optionnelle)
  validates :image_mobile,
            content_type: ['image/png', 'image/jpeg', 'image/webp'],
            size: { less_than: 5.megabytes, message: 'doit faire moins de 5 Mo' },
            allow_blank: true

  # Validation du Poids (1 par défaut)
  validates :weight, numericality: { greater_than_or_equal_to: 1 }, presence: true

  # --- 3. SCOPES ---
  
  # Pubs actives (statut + dates)
  scope :currently_active, -> {
    where(active: true)
      .where('start_date IS NULL OR start_date <= ?', Date.current)
      .where('end_date IS NULL OR end_date >= ?', Date.current)
  }

  # Filtre intelligent selon l'utilisateur
  scope :relevant_for, ->(user) {
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
    self.active &&
    (self.start_date.nil? || self.start_date <= Date.current) &&
    (self.end_date.nil? || self.end_date >= Date.current)
  end

  # ALGORITHME DE SÉLECTION PONDÉRÉE
  def self.pick_weighted_random(user = nil)
    # 1. On récupère les candidats (Actifs + Pertinents pour le user)
    candidates = self.currently_active.relevant_for(user)
    
    return nil if candidates.empty?

    # 2. Somme des poids
    total_weight = candidates.sum(:weight)
    
    # 3. Tirage au sort
    random_point = rand(1..total_weight)
    current_weight = 0

    # 4. Parcours pour trouver l'élu
    candidates.each do |ad|
      current_weight += ad.weight
      return ad if random_point <= current_weight
    end
    
    candidates.first # Sécurité
  end

  # --- 5. TRAITEMENT D'IMAGES (CALLBACKS) ---
  after_commit :process_images, on: [:create, :update]

  private

  def process_images
    # Traite l'image principale
    process_attachment(:image, "ads") if image.attached? && image.blob.saved_change_to_id?
    
    # Traite l'image mobile si elle existe
    process_attachment(:image_mobile, "ads") if image_mobile.attached? && image_mobile.blob.saved_change_to_id?
  end

  def process_attachment(attachment_name, folder_name)
    attachment = self.send(attachment_name)
    # Évite de boucler si déjà WebP
    return if attachment.blob.content_type == "image/webp"

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

      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: webp_tempfile,
        filename: filename,
        content_type: "image/webp",
        key: "#{folder_name}/#{filename}"
      )

      attachment.attachment.update_column(:blob_id, new_blob.id)
      original_blob.purge_later
    end
  rescue => e
    Rails.logger.error("ERREUR WEBP/RESIZE pour Ad ID #{id} (#{attachment_name}): #{e.message}")
  end
end