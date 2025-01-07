# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'csv'

# Import des domaines
csv_text_domaines = File.read(Rails.root.join('lib', 'seeds', 'domaine.csv'), encoding: 'utf-8')
csv_domaines = CSV.parse(csv_text_domaines, headers: true)

domaines_counter = 0

csv_domaines.each do |row|
  domaine = Domaine.find_or_create_by(
    domaine: row['domaine'],
    couleur: row['couleur'],
    svg: row['svg']
  )
  if domaine.save
    puts "Domaine importé : #{domaine.domaine}"
  else
    puts "Erreur lors de l'importation du domaine : #{domaine.errors.full_messages}"
  end

  domaines_counter += 1
end

puts "Nombre total de domaines importés : #{domaines_counter}"

# Import des établissements
csv_text_etablissements = File.read(Rails.root.join('lib', 'seeds', 'etablissements.csv'), encoding: 'utf-8')
csv_etablissements = CSV.parse(csv_text_etablissements, headers: true)

etablissements_counter = 0

csv_etablissements.each do |row|
  etablissement = Etablissement.find_or_create_by(
    name: row['name'],
    region: row['region'],
    academy: row['academy'],
    city: row['city'],
    messagerie: row['messagerie'],
    address: row['address'],
    phone: row['phone'],
    website: row['website'],
    longitude: row['longitude'],
    latitude: row['latitude']
  )
  if etablissement.save
    puts "Établissement importé : #{etablissement.name}"
  else
    puts "Erreur lors de l'importation de l'établissement : #{etablissement.errors.full_messages.join(", ")}"
  end

  etablissements_counter += 1
end

puts "Nombre total d'établissements importés : #{etablissements_counter}"

# Import des pays
csv_text_countries = File.read(Rails.root.join('lib', 'seeds', 'pays.csv'), encoding: 'utf-8')
csv_countries = CSV.parse(csv_text_countries, headers: true)

countries_counter = 0

csv_countries.each do |row|
  country = Country.find_or_create_by(
    country: row['country'],
    country_numeric: row['country_numeric']
  )

  if country.save
    puts "Pays importé : #{country.country}"
  else
    puts "Erreur lors de l'importation du pays : #{country.errors.full_messages.join(", ")}"
  end

  countries_counter += 1
end

puts "Nombre total de pays importés : #{countries_counter}"

# Import des designers
csv_text_designers = File.read(Rails.root.join('lib', 'seeds', 'designers.csv'), encoding: 'utf-8')
csv_designers = CSV.parse(csv_text_designers, headers: true)

designers_counter = 0

csv_designers.each do |row|
  designer = Designer.find_or_create_by(
    nom_designer: row['nom_designer'],
    date_naissance: row['date_naissance'],
    image: row['image'],
    presentation_generale: row['presentation_generale'],
    formation_et_influences: row['formation_et_influences'],
    style_ou_philosophie: row['style_ou_philosophie'],
    creations_majeures: row['creations_majeures'],
    heritage_et_impact: row['heritage_et_impact']
  )

  # Créez un tableau vide pour les pays
  countries = []

  # Vérifiez si les pays dans les colonnes 'country_1', 'country_2', etc., existent et ajoutez-les
  (1..2).each do |i| # Si vous avez deux colonnes de pays
    country_column = row["country_#{i}"]
    if country_column.present?
      country = Country.find_or_create_by(country: country_column)
      countries << country
    end
  end

  # Associer les pays au designer via la table de jointure
  designer.countries = countries

  # Créez un tableau vide pour les domaines
  domaines = []

  # Vérifiez si les domaines dans les colonnes 'domaine_1', 'domaine_2', etc., existent et ajoutez-les
  (1..2).each do |i| # Si vous avez deux colonnes de domaines
    domaine_column = row["domaine_#{i}"]
    if domaine_column.present?
      domaine = Domaine.find_or_create_by(domaine: domaine_column)
      domaines << domaine
    end
  end

  # Associer les domaines au designer via la table de jointure
  designer.domaines = domaines

  # Sauvegarde du designer
  designer.save!

  if designer.save
    puts "Designer importée : #{designer.nom_designer}"
    designers_counter += 1
  else
    puts "Erreur lors de l'importation du designer : #{designer.errors.full_messages.join(', ')}"
  end
  puts
end

puts "#{designers_counter} designers importés avec succès."
# Import des oeuvres

csv_text_oeuvres = File.read(Rails.root.join('lib', 'seeds', 'oeuvres.csv'), encoding: 'utf-8')
csv_oeuvres = CSV.parse(csv_text_oeuvres, headers: true)

oeuvres_counter = 0

csv_oeuvres.each do |row|
  # Initialisation des designers principaux
  main_designer = Designer.find_or_create_by(nom_designer: row['nom_designer']) do |designer|
    designer.date_naissance = row['date_naissance']
    designer.image = row['image']
    designer.presentation_generale = row['presentation_generale']
  end

  # Création ou association d'une œuvre
  oeuvre = Oeuvre.new(
    nom_oeuvre: row['nom_oeuvre'],
    date_oeuvre: row['date_oeuvre'],
    presentation_generale: row['presentation_generale'],
    contexte_historique: row['contexte_historique'],
    materiaux_et_innovations_techniques: row['materiaux_et_innovations_techniques'],
    concept_et_inspiration: row['concept_et_inspiration'],
    dimension_esthetique: row['dimension_esthetique'],
    impact_et_message: row['impact_et_message'],
    image: row['image']
  )

  # Association du domaine
  domaine = Domaine.find_or_create_by(domaine: row['domaine'])
  if domaine.nil?
    puts "Erreur : Le domaine '#{row['domaine']}' n'existe pas."
    next
  end
  oeuvre.domaine = domaine
  # Initialisation des designers supplémentaires
  designers = []
  (1..2).each do |i| # Ajustez ce nombre si le CSV peut contenir plus de designers
    designer_name = row["nom_designer_#{i}"]
    next unless designer_name.present? # Ignorer si la colonne est vide

    designer = Designer.find_or_create_by(nom_designer: designer_name)
    designers << designer
  end

  # Ajouter le designer principal uniquement s'il n'y a pas d'autres designers
  if designers.empty?
    designers << main_designer unless main_designer.nil?
  end

  # Associer tous les designers à l'œuvre
  oeuvre.designers = designers


  # Sauvegarde de l'œuvre
  if oeuvre.save
    puts "Oeuvre importée : #{oeuvre.nom_oeuvre}"
    oeuvres_counter += 1
  else
    puts "Erreur lors de l'importation de l'œuvre : #{oeuvre.errors.full_messages.join(', ')}"
  end
end

puts "Nombre total d'œuvres importées : #{oeuvres_counter}"
