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
    description: row['description']
  )
  country = Country.find_or_create_by(country: row['country'])
  designer.country = country


  if designer.save
    puts "Designer importé : #{designer.nom_designer}"
  else
    puts "Erreur lors de l'importation du designer : #{designer.errors.full_messages}"
  end

  designers_counter += 1
end

puts "Nombre total de designers importés : #{designers_counter}"


# Import des oeuvres
csv_text_oeuvres = File.read(Rails.root.join('lib', 'seeds', 'oeuvres.csv'), encoding: 'utf-8')
csv_oeuvres = CSV.parse(csv_text_oeuvres, headers: true)

oeuvres_counter = 0

csv_oeuvres.each do |row|
  designer = Designer.find_or_create_by(nom_designer: row['nom_designer']) do |designer|
    designer.date_naissance = row['date_naissance']
    designer.image = row['image']
    designer.description = row['description']
    country = Country.find_or_create_by(country: row['country'])
    designer.country = country
  end

  oeuvre = designer.oeuvres.build(
    nom_oeuvre: row['nom_oeuvre'],
    date_oeuvre: row['date_oeuvre'],
    description: row['description'],
    image: row['image']
  )

  domaine = Domaine.find_or_create_by(domaine: row['domaine'])
  if domaine.nil?
    puts "Erreur : Le domaine '#{row['domaine']}' n'existe pas."
    next
  end

  oeuvre.domaine = domaine

  if oeuvre.save
    puts "Oeuvre importée : #{oeuvre.nom_oeuvre}"
  else
    puts "Erreur lors de l'importation de l'oeuvre : #{oeuvre.errors.full_messages}"
  end

  oeuvres_counter += 1
end

puts "Nombre total d'oeuvres importées : #{oeuvres_counter}"
