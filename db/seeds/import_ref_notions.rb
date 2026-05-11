require 'csv'

puts "--- Démarrage de l'association Références <-> Notions ---"

csv_path = Rails.root.join('db', 'seeds', 'ref-notions.csv')
unless File.exist?(csv_path)
  puts "❌ Erreur : Fichier #{csv_path} introuvable."
  exit
end

stats = {
  success: 0,
  ref_not_found: 0,
  notion_not_found: 0,
  total_rows: 0
}

errors = []

CSV.foreach(csv_path, headers: true) do |row|
  stats[:total_rows] += 1
  ref_name = row['Nom de la référence']&.strip
  notions_string = row['Notions']

  if ref_name.blank?
    errors << "Ligne #{$.}: Nom de référence vide."
    next
  end

  # Trouver la référence
  reference = Reference.find_by(nom_reference: ref_name)
  
  if reference.nil?
    stats[:ref_not_found] += 1
    errors << "Référence introuvable : \"#{ref_name}\""
    next
  end

  # Parser les notions
  notion_names = (notions_string || "").split(',').map(&:strip).reject(&:blank?)
  
  notions_to_add = []
  notion_names.each do |n_name|
    notion = Notion.find_by(name: n_name)
    if notion
      notions_to_add << notion
    else
      stats[:notion_not_found] += 1
      errors << "Notion introuvable : \"#{n_name}\" (pour la réf : #{ref_name})"
    end
  end

  if notions_to_add.any?
    reference.notions = notions_to_add
    stats[:success] += 1
  end
end

puts "\n--- Rapport d'importation ---"
puts "📊 Total lignes traitées : #{stats[:total_rows]}"
puts "✅ Références mises à jour : #{stats[:success]}"
puts "⚠️ Références introuvables : #{stats[:ref_not_found]}"
puts "💡 Notions introuvables (total) : #{stats[:notion_not_found]}"

if errors.any?
  puts "\n❌ Détails des erreurs :"
  errors.each { |err| puts "- #{err}" }
end

puts "\n--- Fin du script ---"
