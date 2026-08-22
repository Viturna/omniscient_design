namespace :images do
  desc "Strip ICC profiles from all existing WebP images to fix iOS WebKit crash (err=-50)"
  task fix_webp_icc_profiles: :environment do
    require 'image_processing/vips'

    # Force l'exécution synchrone pour éviter de saturer le pool de connexions à la DB
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline

    begin
      # Modèles concernés
      models = [DesignerImage, StudioImage, ReferenceImage]

      models.each do |model_class|
        puts "=== Traitement des images pour #{model_class.name} ==="
        
        # Utilisation de find_each pour traiter par lots (par défaut 1000 à la fois) et éviter d'exploser la RAM
        model_class.find_each do |record|
          next unless record.file.attached?
          
          blob = record.file.blob
          next unless blob.content_type == 'image/webp'

          begin
            blob.open(tmpdir: Rails.root.join('tmp')) do |temp_file|
              # On utilise Vips au lieu de MiniMagick car imagemagick n'est pas dans ton Dockerfile
              webp_tempfile = ImageProcessing::Vips
                .source(temp_file.path)
                .saver(strip: true)
                .call

              # On génère un nouveau nom et fichier
              random_name = SecureRandom.hex(10)
              filename = "#{random_name}.webp"
              

              folder = model_class.name.underscore.split('_').first.pluralize # designer -> designers
              
              # Création du nouveau blob propre
              new_blob = ActiveStorage::Blob.create_and_upload!(
                io: webp_tempfile,
                filename: filename,
                content_type: 'image/webp',
                key: "#{folder}/#{filename}"
              )

              # Mise à jour de l'attachement
              record.file.attachment.update_column(:blob_id, new_blob.id)
              
              # Suppression synchrone de l'ancien fichier corrompu pour ne pas encombrer les files d'attente
              blob.purge
              
              puts "✅ [#{model_class.name} ID: #{record.id}] Profil ICC supprimé avec succès."

              # Pause pour laisser respirer la base de données
              sleep 0.1
            end
          rescue StandardError => e
            puts "❌ [#{model_class.name} ID: #{record.id}] ERREUR: #{e.message}"
          end
        end
      end
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
      puts "=== Terminé ! ==="
    end
  end
end
