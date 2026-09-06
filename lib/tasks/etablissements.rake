namespace :etablissements do
  desc "Importer ou mettre à jour les établissements depuis les fichiers CSV"
  task import: :environment do
    require 'csv'

    def extract_uai_from_email(email_string)
      return nil if email_string.blank?
      match = email_string.strip.match(/^(?:ce\.)?([0-9]{7}[a-zA-Z])@/i)
      match ? match[1].upcase : nil
    end

    def import_csv(file_path, is_international: false)
      return puts "⚠️ Fichier introuvable : #{file_path}" unless File.exist?(file_path)

      puts "\n📂 Importation depuis : #{File.basename(file_path)}"
      csv_text = File.read(file_path, encoding: 'utf-8')
      csv = CSV.parse(csv_text, headers: true, col_sep: ';')
      new_count = 0
      updated_count = 0

      csv.each do |row|
        uai = is_international ? row['Identifiant_de_l_etablissement'] : (extract_uai_from_email(row['Mail']) || row['Identifiant_de_l_etablissement'])
        next unless uai.present?

        etab = Etablissement.find_or_initialize_by(uai: uai)
        is_new = etab.new_record?

        city_val = row['Nom_commune'] || (row['Adresse_3'].to_s.split(' ').drop(1).join(' ') if row['Adresse_3'].present?)

        etab.assign_attributes(
          name: row['Nom_etablissement'],
          address: [row['Adresse_1'], row['Adresse_2'], row['Adresse_3']].reject(&:blank?).join(', '),
          city: city_val,
          region: row['Libelle_region'],
          academy: row['Libelle_academie'],
          phone: row['Telephone'],
          website: row['Web'],
          messagerie: row['Mail'],
          latitude: row['latitude'].presence&.to_f,
          longitude: row['longitude'].presence&.to_f,
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

        if etab.save
          is_new ? new_count += 1 : updated_count += 1
        else
          puts "  ⚠️ Erreur (#{row['Nom_etablissement']}) : #{etab.errors.full_messages.join(', ')}"
        end
      end

      puts "  ✅ #{new_count} créés, #{updated_count} mis à jour."
    end

    # 1. Établissements internationaux (Belgique & Suisse)
    import_csv(Rails.root.join('lib', 'seeds', 'etablissements_belgique_suisse.csv'), is_international: true)

    # 2. Établissements français si besoin
    # import_csv(Rails.root.join('lib', 'seeds', 'etablissements2.csv'))
  end
end
