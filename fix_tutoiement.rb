require 'yaml'

content = File.read('config/locales/fr.yml')

replacements = {
  "Votre " => "Ton ",
  "votre " => "ton ",
  "Vos " => "Tes ",
  "vos " => "tes ",
  "Vous " => "Tu ",
  "vous " => "tu ",
  "Veuillez " => "Merci de ",
  "veuillez " => "merci de ",
  "Acceptez-vous" => "Acceptes-tu",
  "Nous vous redirigeons" => "Nous te redirigeons",
  "Partagez" => "Partage",
  "Entrez" => "Entre",
  "Choisissez" => "Choisis",
  "Vous n'avez" => "Tu n'as",
  "Vous avez" => "Tu as",
  "Avez-vous" => "As-tu",
  "Souhaitez-vous" => "Souhaites-tu",
  "souhaitez-vous" => "souhaites-tu",
  "souhaitez" => "souhaites",
  "pouvez" => "peux",
  "êtes-vous" => "es-tu",
  "Êtes-vous" => "Es-tu",
  "êtes" => "es",
  "Vous n'êtes pas autorisé" => "Tu n'es pas autorisé",
  "Cliquez" => "Clique",
  "Vérifiez" => "Vérifie",
  "N'hésitez pas" => "N'hésite pas",
  "Pensez à" => "Pense à",
  "Saisissez" => "Saisis",
  "Sélectionnez" => "Sélectionne",
  "Allez" => "Va",
  "Vous allez" => "Tu vas",
  "Vous devez" => "Tu dois",
  "Vous allez recevoir" => "Tu vas recevoir",
  "allez recevoir" => "vas recevoir",
  "Veuillez entrer" => "Entre",
  "veuillez entrer" => "entre",
  "Veuillez sélectionner" => "Sélectionne",
  "veuillez corriger" => "corrige",
  "Veuillez corriger" => "Corrige",
  "veuillez suivre" => "suis",
  "Veuillez suivre" => "Suis",
  "veuillez vérifier" => "vérifie",
  "Veuillez vérifier" => "Vérifie",
  "veuillez contacter" => "contacte",
  "Veuillez contacter" => "Contacte",
  "veuillez ignorer" => "ignore",
  "Veuillez ignorer" => "Ignore",
  "veuillez cliquer" => "clique",
  "Veuillez cliquer" => "Clique",
  "veuillez modifier" => "modifie",
  "Veuillez modifier" => "Modifie",
  "votre navigateur" => "ton navigateur",
  "Votre navigateur" => "Ton navigateur",
  "Votre compte" => "Ton compte",
  "votre compte" => "ton compte",
  "Votre profil" => "Ton profil",
  "votre profil" => "ton profil",
  "Votre avis" => "Ton avis",
  "votre aide" => "ton aide",
  "Votre aide" => "Ton aide",
  "votre contribution" => "ta contribution",
  "Votre contribution" => "Ta contribution",
  "votre feedback" => "ton feedback",
  "Votre feedback" => "Ton feedback",
  "votre expérience" => "ton expérience",
  "votre adresse e-mail" => "ton adresse e-mail",
  "Votre adresse e-mail" => "Ton adresse e-mail",
  "votre email" => "ton email",
  "votre prénom" => "ton prénom",
  "votre nom" => "ton nom",
  "votre mot de passe" => "ton mot de passe",
  "Votre mot de passe" => "Ton mot de passe",
  "votre statut" => "ton statut",
  "Votre statut" => "Ton statut",
  "votre établissement" => "ton établissement",
  "vous n'ayez" => "tu n'aies",
  "vous n'êtes" => "tu n'es",
  "vous êtes" => "tu es",
  "vous redirigeons" => "te redirigeons",
  "vous serez" => "tu seras",
  "Vous serez" => "Tu seras",
  "vous contacter" => "te contacter",
  "nous vous contactons" => "nous te contactons",
  "nous vous informons" => "nous t'informons",
  "Nous vous informons" => "Nous t'informons",
  "vous a invité" => "t'a invité",
  "vous a attribué" => "t'a attribué",
  "partagée avec vous" => "partagée avec toi",
  "Partagez vos impressions" => "Partage tes impressions",
  "Soumettez" => "Soumets",
  "partageriez-vous" => "partagerais-tu",
  "évalueriez-vous" => "évaluerais-tu",
  "aimeriez-vous" => "aimerais-tu",
  "souhaiteriez-vous" => "souhaiterais-tu",
  "aimeriez voir" => "aimerais voir",
  "souhaiteriez partager" => "souhaiterais partager",
  "avez-vous" => "as-tu",
  "Avez-vous" => "As-tu",
  "Créez" => "Crée",
  "Concentrez-vous" => "Concentre-toi",
  "Retrouvez" => "Retrouve",
  "Naviguez" => "Navigue",
  "Consultez" => "Consulte",
  "Téléchargez" => "Télécharge",
  "Gardez" => "Garde",
  "Suivez" => "Suis",
  "Découvrez" => "Découvre"
}

replacements.each do |k, v|
  content.gsub!(k, v)
end

# Quelques ajustements grammaticaux
content.gsub!("tu a été", "tu as été")
content.gsub!("tu avez", "tu as")
content.gsub!("tu n'avez", "tu n'as")
content.gsub!("tu vous", "tu te")
content.gsub!("pour vous", "pour toi")
content.gsub!("avec vous", "avec toi")
content.gsub!("de vous", "de toi")
content.gsub!("chez vous", "chez toi")
content.gsub!("tu votre", "tu ton")
content.gsub!("tu vos", "tu tes")
content.gsub!("à vous", "à toi")
content.gsub!("merci de entrer", "entre")
content.gsub!("Merci de entrer", "Entre")
content.gsub!("merci de sélectionner", "sélectionne")
content.gsub!("merci de choisir", "choisis")
content.gsub!("Vous y trouverez", "Tu y trouveras")
content.gsub!("vous y trouverez", "tu y trouveras")
content.gsub!("Vous y avez", "Tu y as")
content.gsub!("Vous y", "Tu y")

File.write('config/locales/fr.yml', content)
puts "Tutoiement appliqué à fr.yml"
