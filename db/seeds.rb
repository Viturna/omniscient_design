require 'csv'
require 'uri'

# --- Import des domaines ---
puts "--- Import des Domaines ---"
begin
  csv_text_domaines = File.read(Rails.root.join('lib', 'seeds', 'domaine.csv'), encoding: 'utf-8')
  csv_domaines = CSV.parse(csv_text_domaines, headers: true)
  domaines_counter = 0
  csv_domaines.each do |row|
    domaine = Domaine.find_or_create_by(
      domaine: row['domaine'],
      couleur: row['couleur'],
      svg: row['svg']
    )
    domaines_counter += 1 if domaine.persisted?
  end
  puts "Nombre total de domaines importés/vérifiés : #{domaines_counter}"
rescue Errno::ENOENT
  puts "AVERTISSEMENT : Fichier 'domaine.csv' non trouvé. Importation annulée."
end

# --- Import des notions ---
puts "\n--- Import des Notions ---"
begin
  csv_text_notions = File.read(Rails.root.join('lib', 'seeds', 'notions.csv'), encoding: 'utf-8')
  csv_notions = CSV.parse(csv_text_notions, headers: true)
  notions_counter = 0
  csv_notions.each do |row|
    notion = Notion.find_or_create_by(name: row['name'])
    notions_counter += 1 if notion.persisted?
  end
  puts "Nombre total de notions importées/vérifiés : #{notions_counter}"
rescue Errno::ENOENT
  puts "AVERTISSEMENT : Fichier 'notions.csv' non trouvé. Importation annulée."
end

# ==============================================================================
# --- IMPORT DES ÉTABLISSEMENTS (etablissements2.csv UNIQUEMENT) ---
# ==============================================================================
puts "\n--- Import des Établissements ---"

# Helper pour extraire l'UAI de '0070004S@ac-grenoble.fr' ou 'ce.0350787R@ac-rennes.fr'
def extract_uai_from_email(email_string)
  return nil if email_string.blank?
  match = email_string.strip.match(/^(?:ce\.)?([0-9]{7}[a-zA-Z])@/i)
  match ? match[1].upcase : nil
end

new_etablissements_counter = 0
updated_etablissements_counter = 0

puts "Traitement du fichier : etablissements2.csv..."
new_file_path = Rails.root.join('lib', 'seeds', 'etablissements2.csv')
if File.exist?(new_file_path)
  begin
    csv_text_new = File.read(new_file_path, encoding: 'utf-8')
    # Utilisation du délimiteur point-virgule ';'
    csv_new = CSV.parse(csv_text_new, headers: true, col_sep: ';')

    csv_new.each do |row|
      uai = extract_uai_from_email(row['Mail'])
      
      if uai.nil?
        puts "SKIPPING: UAI non trouvé dans Mail '#{row['Mail']}' pour '#{row['Nom_etablissement']}'"
        next
      end

      etablissement = Etablissement.find_or_initialize_by(uai: uai)
      is_new = etablissement.new_record?

      etablissement.assign_attributes(
        name: row['Nom_etablissement'],
        address: [row['Adresse_1'], row['Adresse_3']].reject(&:blank?).join(', '),
        city: row['Nom_commune'],
        region: row['Libelle_region'],
        academy: row['Libelle_academie'],
        phone: row['Telephone'],
        website: row['Web'],
        messagerie: row['Mail'],
        latitude: row['latitude'].present? ? row['latitude'].to_f : nil,
        longitude: row['longitude'].present? ? row['longitude'].to_f : nil,
        type_etablissement: row['Type_etablissement'],
        statut_public_prive: row['Statut_public_prive'],
        voie_generale: (row['Voie_generale'] == 't'),
        voie_technologique: (row['Voie_technologique'] == 't'),
        voie_professionnelle: (row['Voie_professionnelle'] == 't'),
        post_bac: (row['Post_BAC'] == 't'),
        section_arts: (row['Section_arts'] == 't'),
        section_cinema: (row['Section_cinema'] == 't'),
        section_theatre: (row['Section_theatre'] == 't')
      )

      if etablissement.save
        if is_new
          new_etablissements_counter += 1
        else
          updated_etablissements_counter += 1
        end
      else
        puts "ERREUR: #{etablissement.errors.full_messages.join(", ")} pour UAI #{uai}"
      end
    end
  rescue CSV::MalformedCSVError => e
    puts "ERREUR CSV : Le fichier 'etablissements2.csv' est malformé. Vérifiez le délimiteur (doit être ';'). Erreur: #{e.message}"
  end
else
  puts "AVERTISSEMENT : Fichier 'etablissements2.csv' non trouvé. Importation annulée."
end

puts "\nNombre total de nouveaux établissements créés : #{new_etablissements_counter}"
puts "Nombre d'établissements mis à jour : #{updated_etablissements_counter}"

# ==============================================================================
# --- Import des pays ---
# ==============================================================================
puts "\n--- Import des Pays ---"
begin
  csv_text_countries = File.read(Rails.root.join('lib', 'seeds', 'pays.csv'), encoding: 'utf-8')
  csv_countries = CSV.parse(csv_text_countries, headers: true)
  countries_counter = 0
  csv_countries.each do |row|
    country = Country.find_or_create_by(
      country: row['country'],
      country_numeric: row['country_numeric']
    )
    countries_counter += 1 if country.persisted?
  end
  puts "Nombre total de pays importés/vérifiés : #{countries_counter}"
rescue Errno::ENOENT
  puts "AVERTISSEMENT : Fichier 'pays.csv' non trouvé. Importation annulée."
end

puts "\n--- Seed terminé ! ---"