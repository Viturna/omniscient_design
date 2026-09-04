namespace :storage do
  desc "Check missing images on storage (Garage/S3) without modifying anything"
  task check_missing: :environment do
    service = ActiveStorage::Blob.service
    puts "Storage service actuel: #{service.class.name}"

    models = [
      { class: ReferenceImage, parent_assoc: :reference, name_method: :nom_reference },
      { class: DesignerImage, parent_assoc: :designer, name_method: :nom_designer },
      { class: StudioImage, parent_assoc: :studio, name_method: :nom }
    ]

    total_missing = 0

    models.each do |config|
      model_class = config[:class]
      parent_assoc = config[:parent_assoc]
      name_method = config[:name_method]

      puts "\n=== Analyse de #{model_class.name} (#{model_class.count} enregistrements) ==="
      missing_for_model = 0

      model_class.includes(:file_attachment, :file_blob, parent_assoc).find_each do |record|
        parent = record.public_send(parent_assoc)
        parent_name = parent&.public_send(name_method) || "ID #{record.public_send("#{parent_assoc}_id")}"

        if !record.file.attached?
          missing_for_model += 1
          puts "⚠️ [#{model_class.name} ##{record.id}] Parent: '#{parent_name}' -> Pas de pièce jointe"
        elsif !service.exist?(record.file.blob.key)
          missing_for_model += 1
          puts "❌ [#{model_class.name} ##{record.id}] Parent: '#{parent_name}' -> Blob manquant sur stockage (key: #{record.file.blob.key})"
        end
      end

      puts "👉 Total manquants pour #{model_class.name}: #{missing_for_model}"
      total_missing += missing_for_model
    end

    puts "\n🏁 Total global d'images manquantes : #{total_missing}"
  end

  desc "Clean missing images from database (purges orphan attachments and destroys empty image records)"
  task clean_missing: :environment do
    service = ActiveStorage::Blob.service
    puts "Storage service actuel: #{service.class.name}"

    models = [
      { class: ReferenceImage, parent_assoc: :reference, name_method: :nom_reference },
      { class: DesignerImage, parent_assoc: :designer, name_method: :nom_designer },
      { class: StudioImage, parent_assoc: :studio, name_method: :nom }
    ]

    total_cleaned = 0

    models.each do |config|
      model_class = config[:class]
      parent_assoc = config[:parent_assoc]
      name_method = config[:name_method]

      puts "\n=== Nettoyage de #{model_class.name} ==="
      cleaned_for_model = 0

      model_class.includes(:file_attachment, :file_blob, parent_assoc).find_each do |record|
        parent = record.public_send(parent_assoc)
        parent_name = parent&.public_send(name_method) || "ID #{record.public_send("#{parent_assoc}_id")}"

        if !record.file.attached?
          record.destroy
          cleaned_for_model += 1
          puts "🗑️ Supprimé [#{model_class.name} ##{record.id}] ('#{parent_name}') car sans pièce jointe."
        elsif !service.exist?(record.file.blob.key)
          blob = record.file.blob
          # Supprime l'attachement corrompu et le blob
          record.file.purge
          record.destroy
          cleaned_for_model += 1
          puts "🗑️ Supprimé [#{model_class.name} ##{record.id}] ('#{parent_name}') car fichier introuvable sur stockage (key: #{blob.key})."
        end
      end

      puts "👉 Total nettoyés pour #{model_class.name}: #{cleaned_for_model}"
      total_cleaned += cleaned_for_model
    end

    puts "\n🏁 Nettoyage terminé ! Total supprimé : #{total_cleaned}"
  end
end
