require 'csv'
require 'uri'

# ==============================================================================
# --- 1. IMPORT DES DONNÉES CSV (Domaines, Notions, Établissements, Pays) ---
# ==============================================================================

# --- Domaines ---
# puts "--- Import des Domaines ---"
# begin
#   csv_text = File.read(Rails.root.join('lib', 'seeds', 'domaine.csv'), encoding: 'utf-8')
#   csv = CSV.parse(csv_text, headers: true)
#   count = 0
#   csv.each do |row|
#     domaine = Domaine.find_or_create_by(domaine: row['domaine']) do |d|
#       d.couleur = row['couleur']
#       d.svg = row['svg']
#     end
#     count += 1 if domaine.persisted?
#   end
#   puts "✅ Domaines : #{count}"
# rescue Errno::ENOENT
#   puts "⚠️ Fichier 'domaine.csv' non trouvé."
# end

# --- Notions ---
puts "🌱 Création de l'architecture Thèmes > Notions > Verbes..."

# On nettoie pour éviter les doublons avec les anciennes versions
Verb.destroy_all
Notion.destroy_all

definitions = {
  "Composition & Structure" => {
    "Accumulation" => ["Empilement", "Amas", "Collection"],
    "Archétype" => ["Modèle standard", "Patron originel", "Matrice universelle"],
    "Articulation" => ["Charnière", "Pivot", "Jointure"],
    "Combinaison" => ["Mixage", "Assortiment", "Permutation"],
    "Complémentarité" => ["Emboîtement", "Appairage", "Synergie"],
    "Composition" => ["Agencement", "Mise en page", "Disposition"],
    "Concentration" => ["Focalisation", "Convergence", "Densité"],
    "Confrontation" => ["Face-à-face", "Opposition", "Choc visuel"],
    "Connexion" => ["Câblage", "Maillage", "Réseautage"],
    "Déconstruction" => ["Démembrement", "Dislocation", "Analyse structurelle"],
    "Densification" => ["Compactage", "Resserrement", "Saturation spatiale"],
    "Déséquilibre" => ["Porte-à-faux", "Basculement", "Asymétrie"],
    "Disparition" => ["Effacement", "Gommage", "Escamotage"],
    "Dissolution" => ["Dilution", "Fonte", "Dispersibilité"],
    "Enfermement" => ["Cloisonnement", "Encagement", "Verrouillage"],
    "Équilibre" => ["Contrepoids", "Équilibrage", "Stabilisation"],
    "Hiérarchisation" => ["Classement", "Ordonnancement", "Mise en exergue"],
    "Inclusion" => ["Encastrement", "Incrustation", "Englobement"],
    "Insertion" => ["Introduction", "Glissement", "Intercalation"],
    "Intégration" => ["Assimilation", "Incorporation", "Fusion contextuelle"],
    "Liaison" => ["Nouage", "Soudure", "Connectique"],
    "Mise en abyme" => ["Récursivité", "Auto-référence", "Répétition interne"],
    "Ornement" => ["Décoration", "Parure", "Enjolivement"],
    "Ornementation" => ["Cisèlerie", "Broderie", "Moulure"],
    "Répétition" => ["Itération", "Bégaiement", "Duplication"],
    "Stratification" => ["Feuilletez", "Superposition", "Sédimentation"],
    "Unification" => ["Monobloc", "Lissage", "Homogénéisation"],
    "Uniformisation" => ["Standardisation", "Nivellement", "Conformité"]
  },
  "Dynamique & Temporalité" => {
    "Apparition" => ["Émergence", "Surgissement", "Révélation"],
    "Ascension" => ["Élévation", "Levage", "Grimpée"],
    "Attraction" => ["Magnétisme", "Gravitation", "Aspiration"],
    "Bifurcation" => ["Embranchement", "Déviation", "Divergence"],
    "Chute" => ["Descente", "Effondrement", "Gravité"],
    "Circulation" => ["Flux", "Parcours", "Déambulation"],
    "Déploiement" => ["Dépliage", "Étirement", "Ouverture"],
    "Diffusion" => ["Propagation", "Éparpillement", "Rayonnement"],
    "Durabilité" => ["Résistance", "Pérennisation", "Maintenance"],
    "Dynamisation" => ["Activation", "Impulsion", "Mise en mouvement"],
    "Éphémère" => ["Obsolescence programmée", "Évanescence", "Temporisation"],
    "Évolution" => ["Darwinisme formel", "Maturation", "Progression"],
    "Exploration" => ["Arpentage", "Sondage", "Investigation"],
    "Extension" => ["Rallonge", "Annexion", "Prolongement"],
    "Gradation" => ["Échelonnement", "Nuancier", "Palier"],
    "Interaction" => ["Réactivité", "Feedback", "Dialogue interface"],
    "Mobilité" => ["Roulement", "Glissement", "Portabilité"],
    "Mutation" => ["Métamorphose", "Changement d'état", "Altération génétique"],
    "Nomadisme" => ["Itinérance", "Modularité mobile", "Transportabilité"],
    "Oscillation" => ["Balancement", "Ondulation", "Va-et-vient"],
    "Pérennité" => ["Conservation", "Fossilisation", "Immortalisation"],
    "Progression" => ["Avancement", "Séquençage", "Développement"],
    "Régénération" => ["Recyclage", "Réemploi", "Renaissance"],
    "Régression" => ["Retour en arrière", "Déclin", "Primitivisme"],
    "Régulation" => ["Modération", "Contrôle de flux", "Temporisation"],
    "Rotation" => ["Pivotement", "Révolution", "Tournoiement"],
    "Suspension" => ["Accrochage", "Lévitation", "Flottement"],
    "Temporalité" => ["Chronologie", "Rythme", "Datation"],
    "Vibration" => ["Tremblement", "Résonance", "Pulsation"]
  },
  "Forme & Matière" => {
    "Adaptation" => ["Ajustement", "Flexibilité", "Conformation"],
    "Amplification" => ["Grossissement", "Élargissement", "Renforcement"],
    "Atténuation" => ["Adoucissement", "Amortissement", "Feutrage"],
    "Coloration" => ["Teinture", "Pigmentation", "Peinture"],
    "Compression" => ["Écrasement", "Pressage", "Emboutissage"],
    "Courbure" => ["Cintrage", "Pliage courbe", "Arrondissement"],
    "Déformation" => ["Torsion", "Étirement", "Malléabilité"],
    "Dématérialisation" => ["Virtualisation", "Numérisation", "Éthérisation"],
    "Désaturation" => ["Délavage", "Grisement", "Pâleur"],
    "Diminution" => ["Rétrécissement", "Amoindrissement", "Atrophie"],
    "Distorsion" => ["Anamorphose", "Glitch", "Warping"],
    "Diversification" => ["Variété", "Hétérogénéité", "Panachage"],
    "Dualité" => ["Contraste", "Binarité", "Dichotomie"],
    "Évasement" => ["Élargissement conique", "Entonnoir", "Épanouissement"],
    "Fluidité" => ["Liquéfaction", "Coulure", "Écoulement"],
    "Fusion" => ["Alliage", "Soudure thermique", "Amalgame"],
    "Hybridation" => ["Greffe", "Croisement", "Métissage"],
    "Inversion" => ["Retournement", "Négatif", "Symétrie inverse"],
    "Légèreté" => ["Ajourage", "Suspension pneumatique", "Fine structure"],
    "Lourdeur" => ["Lestage", "Ancrage", "Massivité"],
    "Magnification" => ["Agrandissement", "Zoom", "Macro"],
    "Matérialisation" => ["Concrétisation", "Prototypage", "Impression 3D"],
    "Minimalisation" => ["Épuration", "Réduction", "Synthèse"],
    "Modulation" => ["Variation paramétrique", "Réglage", "Tessellation"],
    "Opacité" => ["Occultation", "Masquage", "Obstruction"],
    "Pureté" => ["Nettoyage", "Clarification", "Distillation"],
    "Reflet" => ["Miroir", "Brillance", "Spécularité"],
    "Réfraction" => ["Diffraction", "Prisme", "Déviation optique"],
    "Rétention" => ["Contenant", "Réservoir", "Captation"],
    "Rigidité" => ["Durcissement", "Armature", "Raidissement"],
    "Rugosité" => ["Texturisation", "Grenage", "Abrasion"],
    "Saturation" => ["Intensification", "Vivacité", "Remplissage"],
    "Solidification" => ["Cristallisation", "Durcissement", "Gel"],
    "Transformation" => ["Remodelage", "Conversion", "Refonte"],
    "Translucidité" => ["Voilage", "Dépolissage", "Tamisage"],
    "Transparence" => ["Vitrage", "Invisibilité", "Clarté"],
    "Variation" => ["Déclinaison", "Alternative", "Modification"]
  },
  "Perception & Sens" => {
    "Appropriation" => ["Personnalisation", "Customisation", "Marquage"],
    "Détournement" => ["Hack", "Réinterprétation", "Usage détourné"],
    "Discrétion" => ["Camouflage", "Furtivité", "Sobriété"],
    "Évocation" => ["Allusion", "Suggestion", "Rappel"],
    "Exagération" => ["Caricature", "Hypertrophie", "Surenchère"],
    "Harmonie" => ["Accord", "Euphonie", "Proportion"],
    "Iconisation" => ["Pictogramme", "Emblème", "Signalétique"],
    "Illusion" => ["Trompe-l'œil", "Mirage", "Faux-semblant"],
    "Inattendu" => ["Surprise", "Rupture", "Hasard"],
    "Interprétation" => ["Traduction", "Exégèse", "Lecture"],
    "Irradiation" => ["Halo", "Glow", "Aura"],
    "Manipulation" => ["Influence", "Guidage", "Affordance"],
    "Narration" => ["Storytelling", "Scénario", "Séquence"],
    "Perception" => ["Vision", "Ressenti", "Appréhension sensorielle"],
    "Polarisation" => ["Orientation", "Focalisation magnétique", "Attraction/Répulsion"],
    "Réflexion" => ["Miroitement", "Écho", "Renvoi"],
    "Sensibilisation" => ["Éveil", "Pédagogie", "Alerte"],
    "Simulation" => ["Maquette virtuelle", "Jumeau numérique", "Imitation"],
    "Sublimation" => ["Idéalisation", "Transcendance", "Raffinement"],
    "Symbolisation" => ["Métaphore", "Allégorie", "Signe"],
    "Transposition" => ["Transfert", "Métaphore spatiale", "Décalage"]
  },
  "Stratégie & Procédés" => {
    "Collaboration" => ["Co-création", "Partage", "Intelligence collective"],
    "Conception" => ["Idéation", "Design thinking", "Esquisse"],
    "Construction" => ["Bâtiment", "Édification", "Fabrication"],
    "Dérivation" => ["Branchement", "Déclinaison produit", "Spin-off"],
    "Élaboration" => ["Raffinement", "Finition", "Mise au point"],
    "Formalisation" => ["Dessin technique", "Spécification", "Normalisation"],
    "Imbrication" => ["Tuilage", "Chevauchement", "Interdépendance"],
    "Inachèvement" => ["Non-finito", "Work in progress", "Ouvert"],
    "Innovation" => ["Rupture technologique", "Brevet", "Nouveauté"],
    "Juxtaposition" => ["Coexistence", "Côte-à-côte", "Parallélisme"],
    "Modularité" => ["Préfabrication", "Système", "Élément standard"],
    "Normalisation" => ["Calibrage", "Respect des normes", "Certification"],
    "Optimisation" => ["Rendement", "Efficience", "Gain de place"],
    "Organisation" => ["Planification", "Logistique", "Structuration"],
    "Projection" => ["Anticipation", "Extrapolation", "Perspective"],
    "Rationalisation" => ["Analyse", "Logique", "Simplification process"],
    "Réappropriation" => ["Revendication", "Do It Yourself", "Hacking culturel"],
    "Réhabilitation" => ["Rénovation", "Restauration", "Upcycling"],
    "Regroupement" => ["Cluster", "Catégorisation", "Famille"],
    "Séparation" => ["Division", "Tri", "Scission"],
    "Simplification" => ["Réductionnisme", "Essentialisme", "Facilité d'usage"],
    "Stabilisation" => ["Ancrage", "Fixation", "Pérennité technique"],
    "Valorisation" => ["Mise en valeur", "Exposition", "Premiumisation"]
  }
}

definitions.each do |theme, notions_hash|
  notions_hash.each do |notion_name, verbs_list|
    # 1. Créer la Notion
    notion = Notion.create!(
      name: notion_name,
      theme: theme
    )
    puts "📂 Notion créée : #{notion.name} (#{theme})"

    # 2. Créer les Verbes liés à cette Notion
    verbs_list.each do |verb_name|
      Verb.create!(
        name: verb_name,
        notion: notion
      )
      puts "   -> Verbe ajouté : #{verb_name}"
    end
  end
end

puts "✨ Terminé ! #{Notion.count} Notions et #{Verb.count} Verbes créés."

# --- Établissements ---
# puts "\n--- Import des Établissements ---"
# def extract_uai_from_email(email_string)
#   return nil if email_string.blank?
#   match = email_string.strip.match(/^(?:ce\.)?([0-9]{7}[a-zA-Z])@/i)
#   match ? match[1].upcase : nil
# end

# file_path = Rails.root.join('lib', 'seeds', 'etablissements2.csv')
# if File.exist?(file_path)
#   begin
#     csv_text = File.read(file_path, encoding: 'utf-8')
#     csv = CSV.parse(csv_text, headers: true, col_sep: ';')
#     new_count = 0
#     updated_count = 0

#     csv.each do |row|
#       uai = extract_uai_from_email(row['Mail'])
#       next unless uai

#       etab = Etablissement.find_or_initialize_by(uai: uai)
#       is_new = etab.new_record?

#       etab.assign_attributes(
#         name: row['Nom_etablissement'],
#         address: [row['Adresse_1'], row['Adresse_3']].reject(&:blank?).join(', '),
#         city: row['Nom_commune'],
#         region: row['Libelle_region'],
#         academy: row['Libelle_academie'],
#         phone: row['Telephone'],
#         website: row['Web'],
#         messagerie: row['Mail'],
#         latitude: row['latitude'].presence&.to_f,
#         longitude: row['longitude'].presence&.to_f,
#         type_etablissement: row['Type_etablissement'],
#         statut_public_prive: row['Statut_public_prive'],
#         voie_generale: (row['Voie_generale'] == 't'),
#         voie_technologique: (row['Voie_technologique'] == 't'),
#         voie_professionnelle: (row['Voie_professionnelle'] == 't'),
#         post_bac: (row['Post_BAC'] == 't'),
#         section_arts: (row['Section_arts'] == 't'),
#         section_cinema: (row['Section_cinema'] == 't'),
#         section_theatre: (row['Section_theatre'] == 't')
#       )

#       if etab.save
#         is_new ? new_count += 1 : updated_count += 1
#       end
#     end
#     puts "✅ Établissements : #{new_count} créés, #{updated_count} mis à jour."
#   rescue CSV::MalformedCSVError => e
#     puts "❌ Erreur CSV Établissements : #{e.message}"
#   end
# else
#   puts "⚠️ Fichier 'etablissements2.csv' non trouvé."
# end

# --- Pays ---
# puts "\n--- Import des Pays ---"
# begin
#   csv_text = File.read(Rails.root.join('lib', 'seeds', 'pays.csv'), encoding: 'utf-8')
#   csv = CSV.parse(csv_text, headers: true)
#   count = 0
#   csv.each do |row|
#     country = Country.find_or_create_by(country: row['country']) do |c|
#       c.country_numeric = row['country_numeric']
#     end
#     count += 1 if country.persisted?
#   end
#   puts "✅ Pays : #{count}"
# rescue Errno::ENOENT
#   puts "⚠️ Fichier 'pays.csv' non trouvé."
# end


# ==============================================================================
# --- 2. GESTION DES BADGES (Simple String) ---
# ==============================================================================
# puts "\n--- Gestion des Badges ---"

# badges_data = [
#   # --- SPÉCIAUX ---
#   { name: "Omniscient User", category: "special", level: "standard", description: "Bienvenue dans l'aventure ! Tu as créé ton compte.", filename: "omniscient_user.png" },
#   { name: "Early Adopter", category: "special", description: "Tu fais partie des 100 premiers membres historiques.", filename: "early_adopter.png" },
#   { name: "Donateur", category: "special", level: "standard", description: "Merci pour ton soutien financier au projet.", filename: "donateur.png" },
#   { name: "Community Member", category: "special", level: "standard", description: "Tu suis l'actualité du design sur tous nos réseaux.", filename: "community.png" },
#   { name: "Dans les moindres détails", category: "special", description: "Tu as trouvé le secret caché !", filename: "details.png" },
#   { name: "Noctambule", category: "special", level: "standard", description: "Connecté entre minuit et 5h du matin. Le design ne dort jamais.", filename: "noctambule.png" },
#   { name: "Multi support", category: "special", level: "standard", description: "Tu utilises l'application Omniscient Design.", filename: "multi_support.png" },

#   # --- CONTRIBUTEURS (Refs) ---
#   { name: "Contributeur Bronze", category: "contributor", level: "bronze", threshold: 1, description: "1ère contribution validée.", filename: "contributeur_bronze.png" },
#   { name: "Contributeur Argent", category: "contributor", level: "silver", threshold: 10, description: "10 contributions validées.", filename: "contributeur_argent.png" },
#   { name: "Contributeur Or", category: "contributor", level: "gold", threshold: 20, description: "20 contributions validées. Un pilier du site !", filename: "contributeur_or.png" },

#   # --- AMBASSADEURS (Parrainage) ---
#   { name: "Ambassadeur Bronze", category: "ambassador", level: "bronze", threshold: 3, description: "3 filleuls parrainés.", filename: "ambassadeur_bronze.png" },
#   { name: "Ambassadeur Argent", category: "ambassador", level: "silver", threshold: 10, description: "10 filleuls parrainés.", filename: "ambassadeur_argent.png" },
#   { name: "Ambassadeur Or", category: "ambassador", level: "gold", threshold: 20, description: "20 filleuls parrainés.", filename: "ambassadeur_or.png" },

#   # --- INVESTIGATEURS (Feedbacks/Bugs) ---
#   { name: "Investigateur Bronze", category: "investigator", level: "bronze", threshold: 1, description: "1er retour envoyé.", filename: "investigateur_bronze.png" },
#   { name: "Investigateur Argent", category: "investigator", level: "silver", threshold: 5, description: "5 retours envoyés.", filename: "investigateur_argent.png" },
#   { name: "Investigateur Or", category: "investigator", level: "gold", threshold: 10, description: "10 retours envoyés.", filename: "investigateur_or.png" },

#   # --- DONATEURS (Niveaux) ---
#   { name: "Donateur Bronze", category: "donor", level: "bronze", threshold: 5, description: "Don cumulé de 5€.", filename: "donateur_bronze.png" },
#   { name: "Donateur Argent", category: "donor", level: "silver", threshold: 20, description: "Don cumulé de 20€.", filename: "donateur_argent.png" },
#   { name: "Donateur Or", category: "donor", level: "gold", threshold: 50, description: "Don cumulé de 50€.", filename: "donateur_or.png" }
# ]

# badges_data.each do |data|
#   badge = Badge.find_or_initialize_by(name: data[:name])
#   badge.assign_attributes(
#     category: data[:category],
#     level: data[:level],
#     threshold: data[:threshold] || 0,
#     description: data[:description],
#     image_name: data[:filename]
#   )
  
#   if badge.save
#     puts "✅ Badge '#{badge.name}' : OK (Image liée : #{badge.image_name})"
#   else
#     puts "❌ Erreur Badge '#{data[:name]}' : #{badge.errors.full_messages.join(', ')}"
#   end
# end

puts "\n--- Seed terminé ! ---"