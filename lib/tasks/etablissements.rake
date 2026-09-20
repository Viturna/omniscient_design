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

  desc "Importer et mettre à jour les écoles de design, DN MADE, animation et mode"
  task seed_design_schools: :environment do
    schools = [
      { id: "sainte-genevieve-rennes", name: "Lycée Sainte-Geneviève", city: "Rennes", type: "Privé sous contrat", category: "DN MADE", region: "Bretagne", academy: "Rennes" },
      { id: "saint-etienne-cesson", name: "Lycée Saint-Étienne", city: "Cesson-Sévigné", type: "Privé sous contrat", category: "DN MADE", region: "Bretagne", academy: "Rennes" },
      { id: "le-paraclet-quimper", name: "Lycée Le Paraclet", city: "Quimper", type: "Privé sous contrat", category: "DN MADE", region: "Bretagne", academy: "Rennes" },
      { id: "saint-denis-saint-omer", name: "Lycée Saint-Denis", city: "Saint-Omer", type: "Privé sous contrat", category: "DN MADE", region: "Hauts-de-France", academy: "Lille" },
      { id: "gobelins-paris", name: "GOBELINS Paris", city: "Paris", type: "Consulaire", category: "Grande École Consulaire", region: "Ile-de-France", academy: nil },
      { id: "gobelins-annecy", name: "GOBELINS Campus Annecy", city: "Annecy", type: "Consulaire", category: "Grande École Consulaire", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "ecole-design-nantes", name: "L'École de design Nantes Atlantique", city: "Nantes", type: "Consulaire", category: "Grande École Consulaire", region: "Pays de la Loire", academy: nil },
      { id: "penninghen-paris", name: "Penninghen", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "strate-paris", name: "Strate École de Design", city: "Sèvres (Paris)", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "strate-lyon", name: "Strate École de Design", city: "Lyon", type: "Privé", category: "École Privée de Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "camondo-paris", name: "École Camondo", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "camondo-toulon", name: "École Camondo Méditerranée", city: "Toulon", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "ecole-bleue-paris", name: "École Bleue", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "rubika-valenciennes", name: "RUBIKA (Supinfocom / ISD / Supinfogame)", city: "Valenciennes", type: "Privé", category: "École Privée de Design", region: "Hauts-de-France", academy: nil },
      { id: "ecv-bordeaux", name: "ECV Bordeaux (Design, Digital & Animation)", city: "Bordeaux", type: "Privé", category: "École Privée de Design", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "ecv-paris", name: "ECV Paris", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "ecv-nantes", name: "ECV Nantes", city: "Nantes", type: "Privé", category: "École Privée de Design", region: "Pays de la Loire", academy: nil },
      { id: "ecv-lille", name: "ECV Lille", city: "Lille", type: "Privé", category: "École Privée de Design", region: "Hauts-de-France", academy: nil },
      { id: "ecv-lyon", name: "ECV Lyon", city: "Lyon", type: "Privé", category: "École Privée de Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "ecv-aix", name: "ECV Aix-en-Provence", city: "Aix-en-Provence", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "intuit-lab-paris", name: "École Intuit Lab", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "intuit-lab-marseille", name: "École Intuit Lab", city: "Marseille", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "intuit-lab-lyon", name: "École Intuit Lab", city: "Lyon", type: "Privé", category: "École Privée de Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "lisaa-paris", name: "LISAA (Design Graphique, Mode, Intérieur, Animation)", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "lisaa-strasbourg", name: "LISAA Strasbourg", city: "Strasbourg", type: "Privé", category: "École Privée de Design", region: "Grand Est", academy: nil },
      { id: "lisaa-rennes", name: "LISAA Rennes", city: "Rennes", type: "Privé", category: "École Privée de Design", region: "Bretagne", academy: nil },
      { id: "lisaa-nantes", name: "LISAA Nantes", city: "Nantes", type: "Privé", category: "École Privée de Design", region: "Pays de la Loire", academy: nil },
      { id: "lisaa-bordeaux", name: "LISAA Bordeaux", city: "Bordeaux", type: "Privé", category: "École Privée de Design", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "lisaa-toulouse", name: "LISAA Toulouse", city: "Toulouse", type: "Privé", category: "École Privée de Design", region: "Occitanie", academy: nil },
      { id: "lisaa-montpellier", name: "LISAA Montpellier", city: "Montpellier", type: "Privé", category: "École Privée de Design", region: "Occitanie", academy: nil },
      { id: "eartsup-paris", name: "e-artsup Paris", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "eartsup-bordeaux", name: "e-artsup Bordeaux", city: "Bordeaux", type: "Privé", category: "École Privée de Design", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "eartsup-lyon", name: "e-artsup Lyon", city: "Lyon", type: "Privé", category: "École Privée de Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "eartsup-nantes", name: "e-artsup Nantes", city: "Nantes", type: "Privé", category: "École Privée de Design", region: "Pays de la Loire", academy: nil },
      { id: "eartsup-lille", name: "e-artsup Lille", city: "Lille", type: "Privé", category: "École Privée de Design", region: "Hauts-de-France", academy: nil },
      { id: "eartsup-toulouse", name: "e-artsup Toulouse", city: "Toulouse", type: "Privé", category: "École Privée de Design", region: "Occitanie", academy: nil },
      { id: "eartsup-strasbourg", name: "e-artsup Strasbourg", city: "Strasbourg", type: "Privé", category: "École Privée de Design", region: "Grand Est", academy: nil },
      { id: "eartsup-montpellier", name: "e-artsup Montpellier", city: "Montpellier", type: "Privé", category: "École Privée de Design", region: "Occitanie", academy: nil },
      { id: "esma-montpellier", name: "ESMA (Cinéma d'Animation & Design)", city: "Montpellier", type: "Privé", category: "École Privée d'Animation / Design", region: "Occitanie", academy: nil },
      { id: "esma-lyon", name: "ESMA Lyon", city: "Lyon", type: "Privé", category: "École Privée d'Animation / Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "esma-nantes", name: "ESMA Nantes", city: "Nantes", type: "Privé", category: "École Privée d'Animation / Design", region: "Pays de la Loire", academy: nil },
      { id: "esma-toulouse", name: "ESMA Toulouse", city: "Toulouse", type: "Privé", category: "École Privée d'Animation / Design", region: "Occitanie", academy: nil },
      { id: "esma-bordeaux", name: "ESMA Bordeaux", city: "Bordeaux", type: "Privé", category: "École Privée d'Animation / Design", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "esma-rennes", name: "ESMA Rennes", city: "Rennes", type: "Privé", category: "École Privée d'Animation / Design", region: "Bretagne", academy: nil },
      { id: "artfx-montpellier", name: "ARTFX Montpellier (VFX, 3D, Jeu Vidéo)", city: "Montpellier", type: "Privé", category: "École Privée d'Animation / VFX", region: "Occitanie", academy: nil },
      { id: "artfx-lille", name: "ARTFX Plaine Images", city: "Tourcoing (Lille)", type: "Privé", category: "École Privée d'Animation / VFX", region: "Hauts-de-France", academy: nil },
      { id: "georges-melies-orly", name: "École Georges Méliès", city: "Orly", type: "Privé", category: "École Privée d'Animation", region: "Ile-de-France", academy: nil },
      { id: "isart-digital-paris", name: "ISART Digital", city: "Paris", type: "Privé", category: "École Privée Jeu Vidéo / 3D", region: "Ile-de-France", academy: nil },
      { id: "ecole-pivaut-nantes", name: "École Pivaut", city: "Nantes", type: "Privé", category: "École Privée d'Illustration / Animation", region: "Pays de la Loire", academy: nil },
      { id: "ecole-pivaut-rennes", name: "École Pivaut", city: "Rennes", type: "Privé", category: "École Privée d'Illustration / Animation", region: "Bretagne", academy: nil },
      { id: "ecole-pivaut-toulouse", name: "École Pivaut", city: "Toulouse", type: "Privé", category: "École Privée d'Illustration / Animation", region: "Occitanie", academy: nil },
      { id: "ecole-conde-paris", name: "Écoles de Condé Paris", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "ecole-conde-lyon", name: "Écoles de Condé Lyon", city: "Lyon", type: "Privé", category: "École Privée de Design", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "ecole-conde-bordeaux", name: "Écoles de Condé Bordeaux", city: "Bordeaux", type: "Privé", category: "École Privée de Design", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "ecole-conde-marseille", name: "Écoles de Condé Marseille", city: "Marseille", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "ecole-conde-toulouse", name: "Écoles de Condé Toulouse", city: "Toulouse", type: "Privé", category: "École Privée de Design", region: "Occitanie", academy: nil },
      { id: "ecole-conde-nancy", name: "Écoles de Condé Nancy", city: "Nancy", type: "Privé", category: "École Privée de Design", region: "Grand Est", academy: nil },
      { id: "ecole-conde-nice", name: "Écoles de Condé Nice", city: "Nice", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "ecole-conde-rennes", name: "Écoles de Condé Rennes", city: "Rennes", type: "Privé", category: "École Privée de Design", region: "Bretagne", academy: nil },
      { id: "ifm-paris", name: "Institut Français de la Mode (IFM)", city: "Paris", type: "Privé", category: "Grande École de Mode", region: "Ile-de-France", academy: nil },
      { id: "esmod-paris", name: "ESMOD International", city: "Paris", type: "Privé", category: "École Privée de Mode", region: "Ile-de-France", academy: nil },
      { id: "esmod-lyon", name: "ESMOD Lyon", city: "Lyon", type: "Privé", category: "École Privée de Mode", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "esdac-aix", name: "ESDAC École de Design", city: "Aix-en-Provence", type: "Privé", category: "École Privée de Design", region: "Provence-Alpes-Côte d'Azur", academy: nil },
      { id: "autograf-paris", name: "Autograf", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "creapole-paris", name: "Creapole", city: "Paris", type: "Privé", category: "École Privée de Design", region: "Ile-de-France", academy: nil },
      { id: "sup-de-creation-paris", name: "Sup de Création", city: "Paris", type: "Privé", category: "École de Création & DA", region: "Ile-de-France", academy: nil },
      { id: "brassart-paris", name: "BRASSART", city: "Paris", type: "Privé", category: "École Privée de Design & Animation", region: "Ile-de-France", academy: nil },
      { id: "brassart-nantes", name: "BRASSART Nantes", city: "Nantes", type: "Privé", category: "École Privée de Design & Animation", region: "Pays de la Loire", academy: nil },
      { id: "brassart-bordeaux", name: "BRASSART Bordeaux", city: "Bordeaux", type: "Privé", category: "École Privée de Design & Animation", region: "Nouvelle-Aquitaine", academy: nil },
      { id: "brassart-lyon", name: "BRASSART Lyon", city: "Lyon", type: "Privé", category: "École Privée de Design & Animation", region: "Auvergne-Rhône-Alpes", academy: nil },
      { id: "brassart-lille", name: "BRASSART Lille", city: "Lille", type: "Privé", category: "École Privée de Design & Animation", region: "Hauts-de-France", academy: nil },
      { id: "brassart-toulouse", name: "BRASSART Toulouse", city: "Toulouse", type: "Privé", category: "École Privée de Design & Animation", region: "Occitanie", academy: nil },
      { id: "autre-ecole", name: "Autre école / Université", city: "Autre", type: "Autre", category: "Autre", region: "Autre", academy: nil }
    ]

    created = 0
    updated = 0
    schools.each do |s|
      etab = Etablissement.find_or_initialize_by(uai: s[:id])
      is_new = etab.new_record?
      etab.name = s[:name]
      etab.city = s[:city]
      etab.statut_public_prive = s[:type]
      etab.type_etablissement = s[:category]
      etab.region = s[:region]
      etab.academy = s[:academy]
      etab.post_bac = true
      etab.section_arts = true
      if etab.save
        is_new ? created += 1 : updated += 1
      else
        puts "  ⚠️ Erreur (#{s[:name]}): #{etab.errors.full_messages.join(', ')}"
      end
    end
    puts "✨ #{created} écoles créées, #{updated} mises à jour avec régions & académies."
  end
end
