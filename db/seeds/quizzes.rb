# db/seeds/quizzes.rb

puts "--- Suppression des anciens quiz ---"
QuizSubmission.destroy_all
QuizAnswer.destroy_all
QuizQuestion.destroy_all
Quiz.destroy_all

def create_quiz(title, domaine_name, questions, type: 'static')
  domaine = Domaine.find_by(domaine: domaine_name)
  
  quiz = Quiz.create!(
    title: title,
    domaine: domaine,
    quiz_type: type,
    estimated_time: (questions.count / 4.0).ceil # Environ 15s par question
  )

  questions.each_with_index do |data, i|
    question = quiz.quiz_questions.create!(content: data[:q], order: i + 1)
    question.quiz_answers.create!(content: data[:a], is_correct: true)
    data[:d].each { |dist| question.quiz_answers.create!(content: dist, is_correct: false) }
  end
  
  puts "Quiz créé : #{title} (#{questions.count} questions)"
  quiz
end

# --- 1. LE BAUHAUS ET SES MAÎTRES ---
create_quiz("Le Bauhaus et ses Maîtres", "Objet", [
  { q: "En quelle année l'école du Bauhaus a-t-elle été fondée ?", a: "1919", d: ["1925", "1909", "1933"] },
  { q: "Qui est le premier directeur et fondateur du Bauhaus ?", a: "Walter Gropius", d: ["Ludwig Mies van der Rohe", "Hannes Meyer", "Le Corbusier"] },
  { q: "Quelle ville a accueilli le Bauhaus de 1925 à 1932 ?", a: "Dessau", d: ["Weimar", "Berlin", "Leipzig"] },
  { q: "La chaise 'Wassily' de Marcel Breuer a été conçue au Bauhaus. Pour quel artiste ?", a: "Wassily Kandinsky", d: ["Paul Klee", "Johannes Itten", "Oskar Schlemmer"] },
  { q: "Quel matériau Marcel Breuer a-t-il été le premier à utiliser pour le mobilier ?", a: "Le tube d'acier cintré", d: ["L'aluminium", "Le contreplaqué moulé", "Le plastique"] },
  { q: "Marianne Brandt était une figure majeure de quel atelier au Bauhaus ?", a: "Métal", d: ["Tissage", "Menuiserie", "Céramique"] },
  { q: "Quelle devise est souvent associée au Bauhaus et à l'architecture moderne ?", a: "Less is more", d: ["Form follows function", "God is in the details", "Truth to materials"] },
  { q: "Quel célèbre professeur du Bauhaus a créé le cours préliminaire sur la couleur ?", a: "Johannes Itten", d: ["László Moholy-Nagy", "Josef Albers", "Paul Klee"] },
  { q: "En quelle année le Bauhaus a-t-il été définitivement fermé par les nazis ?", a: "1933", d: ["1939", "1945", "1930"] },
  { q: "Quel bâtiment iconique de Dessau a été conçu par Gropius pour l'école ?", a: "Le bâtiment principal avec ateliers", d: ["La Villa Savoye", "Le Pavillon de Barcelone", "La Maison de Verre"] },
  { q: "Qui a succédé à Hannes Meyer comme directeur du Bauhaus en 1930 ?", a: "Mies van der Rohe", d: ["Walter Gropius", "Marcel Breuer", "Josef Albers"] },
  { q: "Quel atelier était le plus accessible aux femmes au début du Bauhaus ?", a: "Tissage", d: ["Architecture", "Sculpture", "Peinture"] },
  { q: "Le 'Logo du Bauhaus' (1922) a été conçu par...", a: "Oskar Schlemmer", d: ["Herbert Bayer", "Joost Schmidt", "Laszlo Moholy-Nagy"] },
  { q: "La théière MB 7 (1924) est une œuvre emblématique de...", a: "Marianne Brandt", d: ["Wilhelm Wagenfeld", "Christian Dell", "Otto Rittweger"] },
  { q: "La typographie 'Universal' (1925) a été créée par...", a: "Herbert Bayer", d: ["Jan Tschichold", "Paul Renner", "Erik Spiekermann"] }
])

# --- 2. LES ICÔNES DU DESIGN SCANDINAVE ---
create_quiz("Les Icônes du Design Scandinave", "Objet", [
  { q: "Quel designer danois est l'auteur de la chaise 'Egg' ?", a: "Arne Jacobsen", d: ["Hans Wegner", "Verner Panton", "Finn Juhl"] },
  { q: "Alvar Aalto est un designer originaire de quel pays ?", a: "Finlande", d: ["Suède", "Danemark", "Norvège"] },
  { q: "Quelle entreprise finlandaise a été fondée par Alvar Aalto en 1935 ?", a: "Artek", d: ["Iittala", "Marimekko", "Fritz Hansen"] },
  { q: "La chaise 'Panton Chair' (1967) est la première chaise en...", a: "Plastique injecté d'une seule pièce", d: ["Contreplaqué moulé", "Fibre de verre", "Métal perforé"] },
  { q: "Hans Wegner est surnommé 'Le Maître de la...' ?", a: "Chaise", d: ["Lumière", "Forme", "Ligne"] },
  { q: "Quel designer a créé la lampe 'PH 5' ?", a: "Poul Henningsen", d: ["Louis Poulsen", "Arne Jacobsen", "Verner Panton"] },
  { q: "La chaise 'Wishbone' (CH24) est une création de...", a: "Hans Wegner", d: ["Børge Mogensen", "Kaare Klint", "Nanna Ditzel"] },
  { q: "Quel designer suédois est connu pour ses étagères modulables lancées en 1949 ?", a: "Nils Strinning", d: ["Bruno Mathsson", "Carl Larsson", "Gunnar Asplund"] },
  { q: "Le fauteuil 'Lounge Chair 406' d'Alvar Aalto utilise des bandes de...", a: "Lin", d: ["Cuir", "Coton", "Caoutchouc"] },
  { q: "Quel designer danois a créé la série de lampes 'Flowerpot' ?", a: "Verner Panton", d: ["Poul Kjærholm", "Jørn Utzon", "Grete Jalk"] },
  { q: "La 'Swan Chair' a été conçue pour quel hôtel de Copenhague ?", a: "SAS Royal Hotel", d: ["Hôtel de la Ville", "Plaza Hotel", "Grand Hotel"] },
  { q: "Quel designer est à l'origine du tabouret 'Stool 60' ?", a: "Alvar Aalto", d: ["Eero Aarnio", "Tapio Wirkkala", "Kaj Franck"] },
  { q: "La chaise 'Series 7' d'Arne Jacobsen est éditée par...", a: "Fritz Hansen", d: ["Carl Hansen", "Muuto", "Hay"] },
  { q: "Qui a conçu le fauteuil 'Ox Chair' ?", a: "Hans Wegner", d: ["Finn Juhl", "Arne Jacobsen", "Poul Volther"] },
  { q: "Quel designer a créé la chaise 'The Chair' (utilisée par JFK en 1960) ?", a: "Hans Wegner", d: ["Finn Juhl", "Arne Jacobsen", "Poul Kjærholm"] },
  { q: "La lampe 'Artichoke' (1958) est l'œuvre de...", a: "Poul Henningsen", d: ["Verner Panton", "Louis Poulsen", "Arne Jacobsen"] },
  { q: "Quel designer suédois a créé le fauteuil 'Jetson' ?", a: "Bruno Mathsson", d: ["Josef Frank", "Gunnar Asplund", "Carl Malmsten"] },
  { q: "La chaise 'Trinidad' est une création de...", a: "Nanna Ditzel", d: ["Grete Jalk", "Louise Campbell", "Cecilie Manz"] },
  { q: "Qui a conçu le vase 'Aalto' (ou Savoy) ?", a: "Alvar Aalto", d: ["Tapio Wirkkala", "Aino Aalto", "Kaj Franck"] },
  { q: "La 'Barcelona Chair' n'est pas scandinave. Qui l'a conçue ?", a: "Mies van der Rohe", d: ["Arne Jacobsen", "Alvar Aalto", "Marcel Breuer"] }
])

# --- 3. L'ÂGE D'OR DU DESIGN ITALIEN ---
create_quiz("L'Âge d'Or du Design Italien", "Objet", [
  { q: "Quelle ville italienne est considérée comme la capitale mondiale du design ?", a: "Milan", d: ["Rome", "Turin", "Florence"] },
  { q: "Quel designer a créé la lampe 'Arco' en 1962 ?", a: "Achille Castiglioni", d: ["Joe Colombo", "Vico Magistretti", "Ettore Sottsass"] },
  { q: "Quelle entreprise a édité la célèbre machine à écrire 'Valentine' ?", a: "Olivetti", d: ["Cassina", "Kartell", "Alessi"] },
  { q: "Quel designer est à l'origine du mouvement Memphis en 1981 ?", a: "Ettore Sottsass", d: ["Michele De Lucchi", "Alessandro Mendini", "Gaetano Pesce"] },
  { q: "La lampe 'Tolomeo' est une création de...", a: "Michele De Lucchi", d: ["Achille Castiglioni", "Richard Sapper", "Enzo Mari"] },
  { q: "Qui a conçu le fauteuil 'UP5' (Donna) évoquant les courbes féminines ?", a: "Gaetano Pesce", d: ["Joe Colombo", "Marco Zanuso", "Franco Albini"] },
  { q: "Quelle marque est célèbre pour ses objets de cuisine ludiques en plastique ?", a: "Alessi", d: ["Kartell", "Magis", "Zanotta"] },
  { q: "Quel designer a créé la bibliothèque 'Bookworm' ?", a: "Ron Arad", d: ["Ettore Sottsass", "Piero Lissoni", "Patricia Urquiola"] },
  { q: "La chaise 'Superleggera' (1957) a été conçue par...", a: "Gio Ponti", d: ["Franco Albini", "Marco Zanuso", "Ignazio Gardella"] },
  { q: "Quelle entreprise a lancé la première chaise entièrement en plastique (1967) ?", a: "Kartell", d: ["Cassina", "Flos", "Artemide"] },
  { q: "Le 'Juicy Salif' (presse-agrume) a été conçu par Philippe Starck pour...", a: "Alessi", d: ["Kartell", "Driade", "Magis"] },
  { q: "Quel designer a créé le luminaire 'Taccia' ?", a: "Achille Castiglioni", d: ["Vico Magistretti", "Gino Sarfatti", "Joe Colombo"] },
  { q: "La lampe 'Atollo' (1977) est l'œuvre de...", a: "Vico Magistretti", d: ["Gae Aulenti", "Mario Bellini", "Richard Sapper"] },
  { q: "Qui est l'architecte du célèbre 'Pirelli Building' à Milan ?", a: "Gio Ponti", d: ["Renzo Piano", "Aldo Rossi", "Carlo Scarpa"] },
  { q: "Quelle marque édite la chaise 'Cab' en cuir de Mario Bellini ?", a: "Cassina", d: ["B&B Italia", "Cappellini", "Poltrona Frau"] },
  { q: "La lampe 'Pipistrello' a été conçue par...", a: "Gae Aulenti", d: ["Patricia Urquiola", "Paola Navone", "Cini Boeri"] },
  { q: "Quel designer a créé la série 'Ibridi' ?", a: "Alessandro Mendini", d: ["Gaetano Pesce", "Enzo Mari", "Richard Sapper"] },
  { q: "Le fauteuil 'Proust' est une icône de quel designer ?", a: "Alessandro Mendini", d: ["Ettore Sottsass", "Gio Ponti", "Andrea Branzi"] },
  { q: "Qui a conçu le 'Valentine' d'Olivetti avec Perry King ?", a: "Ettore Sottsass", d: ["Mario Bellini", "Marcello Nizzoli", "Richard Sapper"] },
  { q: "La lampe 'Parentesi' a été conçue par Castiglioni et...", a: "Pio Manzù", d: ["Richard Sapper", "Enzo Mari", "Vico Magistretti"] },
  { q: "Quelle marque édite la lampe 'Costanza' ?", a: "Luceplan", d: ["Artemide", "Flos", "Foscarini"] },
  { q: "Qui a créé la 'Moka Express' originale en 1933 ?", a: "Alfonso Bialetti", d: ["Gio Ponti", "Achille Castiglioni", "Gino Sarfatti"] },
  { q: "La chaise 'Louis Ghost' (Starck) est éditée par...", a: "Kartell", d: ["Magis", "Cassina", "Driade"] },
  { q: "Quel designer a conçu la radio 'TS 502' ?", a: "Marco Zanuso", d: ["Mario Bellini", "Joe Colombo", "Richard Sapper"] },
  { q: "La lampe 'Eclisse' est l'œuvre de...", a: "Vico Magistretti", d: ["Achille Castiglioni", "Joe Colombo", "Michele De Lucchi"] }
])

# --- 4. L'ARCHITECTURE MODERNISTE : LE CORBUSIER ET MIES ---
create_quiz("L'Architecture Moderniste : Le Corbusier et Mies", "Architecture", [
  { q: "Où se situe la célèbre Villa Savoye ?", a: "Poissy", d: ["Paris", "Marseille", "Nice"] },
  { q: "Quel architecte a formulé les 'Cinq points de l'architecture moderne' ?", a: "Le Corbusier", d: ["Walter Gropius", "Frank Lloyd Wright", "Mies van der Rohe"] },
  { q: "Pour quelle exposition Mies van der Rohe a-t-il conçu son célèbre Pavillon ?", a: "Exposition universelle de 1929 à Barcelone", d: ["Exposition de 1937 à Paris", "Exposition de 1958 à Bruxelles", "Exposition de 1889 à Paris"] },
  { q: "Quel est le vrai nom de Le Corbusier ?", a: "Charles-Édouard Jeanneret-Gris", d: ["Pierre Jeanneret", "Jean Nouvel", "Charles Garnier"] },
  { q: "La 'Cité Radieuse' est située à...", a: "Marseille", d: ["Lyon", "Bordeaux", "Nantes"] },
  { q: "Quel bâtiment new-yorkais est l'œuvre majeure de Mies van der Rohe ?", a: "Seagram Building", d: ["Empire State Building", "Chrysler Building", "Flatiron Building"] },
  { q: "Quelle villa tchèque est une œuvre majeure de Mies van der Rohe ?", a: "Villa Tugendhat", d: ["Villa Savoye", "Villa Stein", "Villa Mairea"] },
  { q: "Le Corbusier a conçu une chapelle célèbre à...", a: "Ronchamp", d: ["Vence", "Firminy", "Evreux"] },
  { q: "Quel système de mesure basé sur la morphologie humaine Le Corbusier a-t-ih inventé ?", a: "Le Modulor", d: ["L'Échelle humaine", "Le Standard", "Le Proportionnel"] },
  { q: "Mies van der Rohe était le dernier directeur de quelle école ?", a: "Le Bauhaus", d: ["L'École des Beaux-Arts", "Vkhutemas", "Black Mountain College"] },
  { q: "Quel slogan définit le style minimaliste de Mies van der Rohe ?", a: "Less is more", d: ["God is in the details", "Form follows function", "Ornament is crime"] },
  { q: "La 'Maison Farnsworth' est située dans quel État américain ?", a: "Illinois", d: ["New York", "Californie", "Pennsylvanie"] },
  { q: "Le Corbusier a conçu la ville de Chandigarh en...", a: "Inde", d: ["Algérie", "Brésil", "France"] },
  { q: "Quel cousin de Le Corbusier a collaboré sur la plupart de ses projets ?", a: "Pierre Jeanneret", d: ["Charlotte Perriand", "Jean Prouvé", "Robert Mallet-Stevens"] },
  { q: "Le bâtiment 'Unité d'Habitation' utilise principalement quel matériau ?", a: "Le béton brut", d: ["La brique", "L'acier", "Le verre"] },
  { q: "Quel architecte a dit : 'Une maison est une machine à habiter' ?", a: "Le Corbusier", d: ["Adolf Loos", "Walter Gropius", "Mies van der Rohe"] },
  { q: "Le Pavillon de l'Esprit Nouveau (1925) est l'œuvre de...", a: "Le Corbusier", d: ["Mallet-Stevens", "Auguste Perret", "Tony Garnier"] },
  { q: "Quel bâtiment de Mies van der Rohe est célèbre pour son usage de l'onyx et du travertin ?", a: "Pavillon de Barcelone", d: ["Lafayette Park", "S.R. Crown Hall", "Lake Shore Drive Apartments"] },
  { q: "La 'Maison Blanche' (Villa Jeanneret-Perret) est la première maison de Le Corbusier à...", a: "La Chaux-de-Fonds", d: ["Genève", "Lausanne", "Paris"] },
  { q: "Quel architecte a conçu la Neue Nationalgalerie à Berlin ?", a: "Mies van der Rohe", d: ["Le Corbusier", "Walter Gropius", "Hannes Meyer"] }
])

# --- 5. LES PIONNIERS DU GRAPHISME MODERNE ---
create_quiz("Les Pionniers du Graphisme Moderne", "Graphisme", [
  { q: "Qui a conçu le célèbre logo 'I Love NY' ?", a: "Milton Glaser", d: ["Saul Bass", "Paul Rand", "Massimo Vignelli"] },
  { q: "Quel graphiste est célèbre pour ses génériques de films pour Alfred Hitchcock ?", a: "Saul Bass", d: ["Milton Glaser", "Paula Scher", "Stefan Sagmeister"] },
  { q: "La typographie 'Helvetica' (1957) a été créée par Max Miedinger et...", a: "Eduard Hoffmann", d: ["Paul Renner", "Adrian Frutiger", "Jan Tschichold"] },
  { q: "Qui a conçu le logo d'IBM, d'UPS et d'ABC ?", a: "Paul Rand", d: ["Massimo Vignelli", "Herb Lubalin", "Lance Wyman"] },
  { q: "Quel mouvement artistique russe a fortement influencé le graphisme moderne ?", a: "Constructivisme", d: ["Futurisme", "Surréalisme", "Impressionnisme"] },
  { q: "Qui a créé la typographie 'Futura' ?", a: "Paul Renner", d: ["Herbert Bayer", "Jan Tschichold", "Eric Gill"] },
  { q: "Quel graphiste a conçu la signalétique du métro de New York en 1970 ?", a: "Massimo Vignelli", d: ["Milton Glaser", "Paula Scher", "Ivan Chermayeff"] },
  { q: "La revue 'Emigre' était pionnière dans quel domaine ?", a: "La typographie numérique", d: ["La photographie", "L'illustration", "La publicité"] },
  { q: "Qui a conçu l'identité visuelle des Jeux Olympiques de Mexico 1968 ?", a: "Lance Wyman", d: ["Otl Aicher", "Paul Rand", "Saul Bass"] },
  { q: "Quel graphiste est l'auteur de l'affiche 'Hope' de Barack Obama ?", a: "Shepard Fairey", d: ["Banksy", "David Carson", "Stefan Sagmeister"] },
  { q: "Qui a écrit 'The New Typography' (Die neue Typographie) en 1928 ?", a: "Jan Tschichold", d: ["Paul Renner", "Herbert Bayer", "László Moholy-Nagy"] },
  { q: "Le style 'Swiss Style' est aussi appelé...", a: "Style International", d: ["Style Moderne", "Style Bauhaus", "Style Minimaliste"] },
  { q: "Qui a fondé le studio Push Pin Studios ?", a: "Milton Glaser", d: ["Saul Bass", "Paul Rand", "Seymour Chwast"] },
  { q: "Quelle typographie a été créée pour les journaux par Stanley Morison en 1931 ?", a: "Times New Roman", d: ["Baskerville", "Garamond", "Didot"] },
  { q: "Qui a conçu l'identité visuelle de la Lufthansa en 1962 ?", a: "Otl Aicher", d: ["Paul Rand", "Herbert Bayer", "Max Bill"] }
])

# --- 6. HISTOIRE DE LA HAUTE COUTURE ---
create_quiz("Histoire de la Haute Couture", "Mode", [
  { q: "Qui est considérée comme la créatrice de la 'Petite Robe Noire' ?", a: "Coco Chanel", d: ["Elsa Schiaparelli", "Jeanne Lanvin", "Madeleine Vionnet"] },
  { q: "En quelle année Christian Dior a-t-il lancé le 'New Look' ?", a: "1947", d: ["1950", "1939", "1945"] },
  { q: "Quel couturier a introduit le 'Smoking' pour femme en 1966 ?", a: "Yves Saint Laurent", d: ["Hubert de Givenchy", "Cristóbal Balenciaga", "Karl Lagerfeld"] },
  { q: "Qui a succédé à Christian Dior après sa mort en 1957 ?", a: "Yves Saint Laurent", d: ["Marc Bohan", "Gianfranco Ferré", "John Galliano"] },
  { q: "Quel couturier espagnol était surnommé 'Le Maître' par ses pairs ?", a: "Cristóbal Balenciaga", d: ["Paco Rabanne", "Manolo Blahnik", "Mariano Fortuny"] },
  { q: "Qui a créé la robe 'Delphos' ?", a: "Mariano Fortuny", d: ["Paul Poiret", "Charles Frederick Worth", "Jean Patou"] },
  { q: "Quel couturier a libéré les femmes du corset au début du XXe siècle ?", a: "Paul Poiret", d: ["Coco Chanel", "Madeleine Vionnet", "Jeanne Paquin"] },
  { q: "Quelle créatrice italienne a collaboré avec Salvador Dalí pour le 'Chapeau-Chaussure' ?", a: "Elsa Schiaparelli", d: ["Miuccia Prada", "Donatella Versace", "Maria Grazia Chiuri"] },
  { q: "Qui a fondé la maison de couture Givenchy en 1952 ?", a: "Hubert de Givenchy", d: ["Jacques Fath", "Pierre Balmain", "Jean-Louis Scherrer"] },
  { q: "Quel couturier a inventé la minijupe dans les années 60 ?", a: "Mary Quant", d: ["André Courrèges", "Pierre Cardin", "Paco Rabanne"] },
  { q: "Qui a créé le tailleur en tweed iconique ?", a: "Coco Chanel", d: ["Jeanne Lanvin", "Nina Ricci", "Sonia Rykiel"] },
  { q: "Quel couturier a conçu la robe de mariée de Grace Kelly ?", a: "Helen Rose", d: ["Hubert de Givenchy", "Christian Dior", "Edith Head"] },
  { q: "Qui a lancé le parfum 'N°5' en 1921 ?", a: "Coco Chanel", d: ["Jean Patou", "Guerlain", "Lanvin"] },
  { q: "Quel couturier est connu pour son style architectural et ses coupes en biais ?", a: "Madeleine Vionnet", d: ["Madame Grès", "Jeanne Lanvin", "Mainbocher"] },
  { q: "Qui a conçu le premier sac à main 'Kelly' pour Hermès ?", a: "Robert Dumas", d: ["Jean-Louis Dumas", "Thierry Hermès", "Charles-Émile Hermès"] },
  { q: "Quel couturier a présenté la collection 'Trapèze' en 1958 ?", a: "Yves Saint Laurent", d: ["Christian Dior", "Hubert de Givenchy", "Pierre Cardin"] },
  { q: "Qui est le créateur de la robe 'Mondrian' ?", a: "Yves Saint Laurent", d: ["André Courrèges", "Pierre Cardin", "Emanuel Ungaro"] },
  { q: "Quel couturier est célèbre pour ses robes en métal et rhodoïd ?", a: "Paco Rabanne", d: ["Pierre Cardin", "André Courrèges", "Thierry Mugler"] },
  { q: "Qui a fondé la plus ancienne maison de couture française encore en activité ?", a: "Jeanne Lanvin", d: ["Coco Chanel", "Hermès", "Louis Vuitton"] },
  { q: "Quel couturier a été le premier à lancer une ligne de prêt-à-porter ('Rive Gauche') ?", a: "Yves Saint Laurent", d: ["Christian Dior", "Pierre Cardin", "Hubert de Givenchy"] }
])

# --- 7. LE DESIGN AMÉRICAIN : EAMES, NELSON & SAARINEN ---
create_quiz("Le Design Américain : Eames, Nelson & Saarinen", "Objet", [
  { q: "Quel couple de designers a créé le 'Lounge Chair & Ottoman' en 1956 ?", a: "Charles & Ray Eames", d: ["George & Marli Nelson", "Eero & Loja Saarinen", "Florence & Hans Knoll"] },
  { q: "Quel designer a conçu la chaise 'Tulip' ?", a: "Eero Saarinen", d: ["Charles Eames", "George Nelson", "Harry Bertoia"] },
  { q: "Quelle entreprise a édité la plupart des créations de George Nelson ?", a: "Herman Miller", d: ["Knoll", "Vitra", "Steelcase"] },
  { q: "Qui a conçu l'horloge 'Ball Clock' ?", a: "George Nelson", d: ["Charles Eames", "Isamu Noguchi", "Alexander Girard"] },
  { q: "Le 'Diamond Chair' en fils d'acier soudés est l'œuvre de...", a: "Harry Bertoia", d: ["Eero Saarinen", "Charles Eames", "Isamu Noguchi"] },
  { q: "Quel architecte a conçu le Gateway Arch à Saint-Louis ?", a: "Eero Saarinen", d: ["Frank Lloyd Wright", "Louis Sullivan", "Philip Johnson"] },
  { q: "La chaise 'LCW' (Lounge Chair Wood) est faite de...", a: "Contreplaqué moulé", d: ["Plastique injecté", "Aluminium", "Fibre de verre"] },
  { q: "Qui a dirigé le département design d'Herman Miller pendant 25 ans ?", a: "George Nelson", d: ["Charles Eames", "Alexander Girard", "Robert Propst"] },
  { q: "La table 'Cyclone' est une création de...", a: "Isamu Noguchi", d: ["George Nelson", "Charles Eames", "Harry Bertoia"] },
  { q: "Quel designer a créé la chaise 'Womb' ?", a: "Eero Saarinen", d: ["Charles Eames", "Florence Knoll", "George Nelson"] },
  { q: "Les Eames ont réalisé un film célèbre intitulé...", a: "Powers of Ten", d: ["Design for Living", "The World of Eames", "Modern Times"] },
  { q: "Quelle école d'art américaine a accueilli les Eames et Saarinen ?", a: "Cranbrook Academy of Art", d: ["RISD", "ArtCenter", "Parsons"] },
  { q: "Qui a conçu le canapé 'Marshmallow' ?", a: "George Nelson (Irving Harper)", d: ["Charles Eames", "Florence Knoll", "Alexander Girard"] },
  { q: "La chaise 'DAX' des Eames signifie...", a: "Dining Armchair X-base", d: ["Design Armchair X-base", "Dynamic Armchair X-base", "Daily Armchair X-base"] },
  { q: "Quel designer a conçu la 'Coffee Table' iconique avec une base en bois sculpté ?", a: "Isamu Noguchi", d: ["George Nelson", "Charles Eames", "Eero Saarinen"] },
  { q: "Florence Knoll a popularisé quel type d'espace de travail ?", a: "L'Open Space moderne", d: ["Le bureau individuel", "Le télétravail", "Le coworking"] },
  { q: "Qui a conçu le terminal TWA à l'aéroport JFK ?", a: "Eero Saarinen", d: ["Frank Lloyd Wright", "Le Corbusier", "Mies van der Rohe"] },
  { q: "La 'Eames Elephant' a été conçue à l'origine en...", a: "Contreplaqué", d: ["Plastique", "Métal", "Résine"] },
  { q: "Quel designer a créé le 'Coconut Chair' ?", a: "George Nelson", d: ["Charles Eames", "Eero Saarinen", "Harry Bertoia"] },
  { q: "Les Eames ont conçu des attelles pour l'armée américaine pendant la 2nde Guerre Mondiale.", a: "Vrai", d: ["Faux"] },
  { q: "Qui a conçu la 'Tulip Table' ?", a: "Eero Saarinen", d: ["Charles Eames", "George Nelson", "Florence Knoll"] },
  { q: "Quelle entreprise a édité les créations d'Eero Saarinen ?", a: "Knoll", d: ["Herman Miller", "Vitra", "Cassina"] },
  { q: "Le fauteuil 'La Chaise' des Eames s'inspire d'une sculpture de...", a: "Gaston Lachaise", d: ["Isamu Noguchi", "Alexander Calder", "Henry Moore"] },
  { q: "Qui a conçu le 'Action Office', ancêtre du cubicule ?", a: "Robert Propst", d: ["George Nelson", "Charles Eames", "Florence Knoll"] },
  { q: "La 'Plastic Side Chair' (DSW) a été présentée pour un concours du...", a: "MoMA", d: ["Met", "Guggenheim", "Whitney"] }
])

# --- 8. LES CHEFS-D'ŒUVRE DE L'ART DÉCO ---
create_quiz("Les Chefs-d'œuvre de l'Art Déco", "Métiers d'arts", [
  { q: "En quelle année s'est tenue l'Exposition internationale des Arts décoratifs à Paris ?", a: "1925", d: ["1900", "1937", "1910"] },
  { q: "Quel paquebot français est considéré comme le temple flottant de l'Art Déco ?", a: "Le Normandie", d: ["Le Titanic", "Le France", "L'Île-de-France"] },
  { q: "Quel célèbre joaillier a créé le style 'Tutti Frutti' ?", a: "Cartier", d: ["Boucheron", "Van Cleef & Arpels", "Chaumet"] },
  { q: "Qui est l'ébéniste le plus emblématique de l'Art Déco ?", a: "Émile-Jacques Ruhlmann", d: ["Louis Majorelle", "André Groult", "Paul Iribe"] },
  { q: "Le Chrysler Building à New York est de style...", a: "Art Déco", d: ["Art Nouveau", "Beaux-Arts", "International Style"] },
  { q: "Quel sculpteur est connu pour ses figures féminines stylisées en bronze ?", a: "Demetre Chiparus", d: ["Paul Manship", "Gaston Lachaise", "Aristide Maillol"] },
  { q: "Le verre opalescent est la spécialité de...", a: "René Lalique", d: ["Daum", "Gallé", "Baccarat"] },
  { q: "Quel créateur a conçu le mobilier de la Villa Noailles ?", a: "Pierre Chareau", d: ["Robert Mallet-Stevens", "Eileen Gray", "Francis Jourdain"] },
  { q: "La 'Maison de Verre' à Paris est l'œuvre de...", a: "Pierre Chareau", d: ["Le Corbusier", "Adolf Loos", "Auguste Perret"] },
  { q: "Quel peintre polonais est une icône de l'Art Déco ?", a: "Tamara de Lempicka", d: ["Sonia Delaunay", "Marie Laurencin", "Fernand Léger"] },
  { q: "Le style Art Déco succède à quel mouvement ?", a: "L'Art Nouveau", d: ["Le Romantisme", "Le Classicisme", "Le Futurisme"] },
  { q: "Quel architecte a conçu le Palais de Chaillot ?", a: "Léon Azéma", d: ["Auguste Perret", "Robert Mallet-Stevens", "Le Corbusier"] },
  { q: "Quel designer a créé le flacon du parfum 'Shalimar' ?", a: "Raymond Guerlain", d: ["René Lalique", "Paul Iribe", "Jean Patou"] },
  { q: "La ferronnerie d'art a été renouvelée par...", a: "Edgar Brandt", d: ["Raymond Subes", "Gilbert Poillerat", "Jean Dunand"] },
  { q: "Quel designer a utilisé la laque de manière magistrale ?", a: "Jean Dunand", d: ["Eileen Gray", "André Mare", "Louis Sue"] }
])

# --- 9. LE DESIGN RADICAL ET MEMPHIS ---
create_quiz("Le Design Radical et Memphis", "Objet", [
  { q: "Dans quelle ville le groupe Memphis a-t-il été fondé ?", a: "Milan", d: ["Turin", "Florence", "Rome"] },
  { q: "Quelle chanson de Bob Dylan a inspiré le nom du groupe Memphis ?", a: "Stuck Inside of Mobile with the Memphis Blues Again", d: ["Like a Rolling Stone", "Blowin' in the Wind", "Knockin' on Heaven's Door"] },
  { q: "Qui était le leader charismatique de Memphis ?", a: "Ettore Sottsass", d: ["Michele De Lucchi", "Alessandro Mendini", "George Sowden"] },
  { q: "Quelle bibliothèque aux formes anthropomorphiques est l'icône de Memphis ?", a: "Carlton", d: ["Casablanca", "Beverly", "Suvretta"] },
  { q: "Quel matériau 'pauvre' Memphis a-t-il utilisé pour ses surfaces ?", a: "Le stratifié plastique (laminé)", d: ["Le carton", "Le bois aggloméré", "Le PVC"] },
  { q: "Le groupe Alchimia a précédé Memphis. Qui en était la figure de proue ?", a: "Alessandro Mendini", d: ["Ettore Sottsass", "Gaetano Pesce", "Andrea Branzi"] },
  { q: "Le mouvement Radical Design est né dans quelle ville à la fin des années 60 ?", a: "Florence", d: ["Milan", "Turin", "Venise"] },
  { q: "Quel studio radical a créé le canapé 'Bazaar' ?", a: "Superstudio", d: ["Archizoom", "UFO", "Gruppo Strum"] },
  { q: "Le projet 'No-Stop City' (1969) est l'œuvre de...", a: "Archizoom", d: ["Superstudio", "Memphis", "Alchimia"] },
  { q: "Le fauteuil 'Proust' de Mendini est un exemple de...", a: "Re-design (ou post-modernisme)", d: ["Modernisme pur", "Minimalisme", "Art Déco"] },
  { q: "Qui a conçu la lampe 'Tahiti' évoquant un canard ?", a: "Ettore Sottsass", d: ["Michele De Lucchi", "Nathalie Du Pasquier", "George Sowden"] },
  { q: "Quel designer français a rejoint le groupe Memphis ?", a: "Nathalie Du Pasquier", d: ["Philippe Starck", "Jean-Paul Gaultier", "Christian Lacroix"] },
  { q: "Le style Memphis se caractérise par des couleurs...", a: "Vives et contrastées", d: ["Pastels et douces", "Sombres et mates", "Naturelles et terreuses"] },
  { q: "Quel couturier célèbre était un grand collectionneur de Memphis ?", a: "Karl Lagerfeld", d: ["Yves Saint Laurent", "Jean-Paul Gaultier", "Valentino"] },
  { q: "Le groupe Memphis s'est dissous en...", a: "1987", d: ["1981", "1995", "1990"] }
])

# --- 10. L'ARCHITECTURE CONTEMPORAINE : LES PRITZKER ---
create_quiz("L'Architecture Contemporaine : Les Pritzker", "Architecture", [
  { q: "Qui a été la première femme à recevoir le prix Pritzker ?", a: "Zaha Hadid", d: ["Kazuyo Sejima", "Yvonne Farrell", "Anne Lacaton"] },
  { q: "Quel architecte français a reçu le Pritzker en 1994 ?", a: "Christian de Portzamparc", d: ["Jean Nouvel", "Dominique Perrault", "Anne Lacaton"] },
  { q: "Qui a conçu le Musée Guggenheim de Bilbao ?", a: "Frank Gehry", d: ["Richard Meier", "Norman Foster", "Renzo Piano"] },
  { q: "Le Louvre Abu Dhabi est l'œuvre de...", a: "Jean Nouvel", d: ["Frank Gehry", "Zaha Hadid", "Rem Koolhaas"] },
  { q: "Quel architecte japonais est connu pour son usage poétique du béton banché ?", a: "Tadao Ando", d: ["Toyo Ito", "Kengo Kuma", "Arata Isozaki"] },
  { q: "Qui a conçu le Shard à Londres ?", a: "Renzo Piano", d: ["Norman Foster", "Richard Rogers", "Zaha Hadid"] },
  { q: "Le centre Heydar Aliyev à Bakou est une création de...", a: "Zaha Hadid", d: ["Rem Koolhaas", "Bjarke Ingels", "Daniel Libeskind"] },
  { q: "Quel architecte néerlandais est l'auteur de 'S,M,L,XL' et fondateur d'OMA ?", a: "Rem Koolhaas", d: ["Ben van Berkel", "Winy Maas", "Francine Houben"] },
  { q: "Le duo d'architectes suisses Herzog & de Meuron est célèbre pour...", a: "Le Tate Modern à Londres", d: ["Le Centre Pompidou", "Le Mucem", "Le Philharmonie de Paris"] },
  { q: "Qui a conçu le Musée du Quai Branly ?", a: "Jean Nouvel", d: ["Renzo Piano", "Richard Rogers", "Frank Gehry"] },
  { q: "Quel architecte a conçu la Philharmonie de l'Elbe à Hambourg ?", a: "Herzog & de Meuron", d: ["Snøhetta", "BIG", "OMA"] },
  { q: "Le projet 'High Line' à New York a été conçu par Diller Scofidio + Renfro et...", a: "James Corner Field Operations", d: ["Snohetta", "OMA", "BIG"] },
  { q: "Quel architecte a conçu la Pyramide du Louvre ?", a: "I.M. Pei", d: ["Richard Meier", "Philip Johnson", "Kevin Roche"] },
  { q: "Le Centre Pompidou est l'œuvre de Renzo Piano et...", a: "Richard Rogers", d: ["Norman Foster", "Jean Nouvel", "Zaha Hadid"] },
  { q: "Quel architecte japonais a conçu la Fondation Louis Vuitton ?", a: "Frank Gehry (il n'est pas japonais)", d: ["Kengo Kuma", "Shigeru Ban", "Tadao Ando"] },
  { q: "Le stade 'Nid d'Oiseau' de Pékin est l'œuvre de...", a: "Herzog & de Meuron", d: ["Zaha Hadid", "Norman Foster", "Gensler"] },
  { q: "Qui a conçu le Jewish Museum à Berlin ?", a: "Daniel Libeskind", d: ["Peter Eisenman", "Richard Meier", "Frank Gehry"] },
  { q: "L'architecte chilien Alejandro Aravena est célèbre pour...", a: "Ses logements sociaux 'Incrémentaux'", d: ["Ses gratte-ciel", "Ses opéras", "Ses stades"] },
  { q: "Quel architecte a conçu la Sydney Opera House ?", a: "Jørn Utzon", d: ["Alvar Aalto", "Eero Saarinen", "Oscar Niemeyer"] },
  { q: "Qui a conçu la ville de Brasilia avec Lucio Costa ?", a: "Oscar Niemeyer", d: ["Luis Barragán", "Paulo Mendes da Rocha", "Affonso Reidy"] },
  { q: "Le prix Pritzker est souvent appelé le 'Prix ___ de l'architecture'.", a: "Nobel", d: ["Oscar", "César", "Palme"] },
  { q: "L'agence SANAA (Sejima & Nishizawa) a conçu quel musée français ?", a: "Louvre-Lens", d: ["Mucem", "Centre Pompidou-Metz", "Fondation Vuitton"] },
  { q: "Qui a conçu le Centre Pompidou-Metz ?", a: "Shigeru Ban", d: ["Toyo Ito", "Kengo Kuma", "Tadao Ando"] },
  { q: "L'architecte Peter Zumthor est célèbre pour quel bâtiment thermal ?", a: "Thermes de Vals", d: ["Bains de Budapest", "Spa de Baden-Baden", "Sources de Vichy"] },
  { q: "Qui a conçu le bâtiment de la Fondation Cartier à Paris ?", a: "Jean Nouvel", d: ["Dominique Perrault", "Renzo Piano", "Christian de Portzamparc"] },
  { q: "Le Burj Khalifa a été conçu par l'agence...", a: "SOM (Skidmore, Owings & Merrill)", d: ["Foster + Partners", "KPF", "Gensler"] },
  { q: "Quel architecte a conçu le Millau Viaduct ?", a: "Norman Foster", d: ["Richard Rogers", "Renzo Piano", "Jean Nouvel"] },
  { q: "Qui a conçu le Vitra Design Museum ?", a: "Frank Gehry", d: ["Zaha Hadid", "Tadao Ando", "Alvaro Siza"] },
  { q: "L'architecte Francis Kéré (Pritzker 2022) est originaire de quel pays ?", a: "Burkina Faso", d: ["Sénégal", "Mali", "Nigeria"] },
  { q: "Qui a conçu l'extension du MoMA en 2004 ?", a: "Yoshio Taniguchi", d: ["Toyo Ito", "Kengo Kuma", "Kazuyo Sejima"] }
])

# --- 11. LES TYPOGRAPHIES DE LÉGENDE ---
create_quiz("Les Typographies de Légende", "Graphisme", [
  { q: "Quelle typographie a été créée par Max Miedinger en 1957 ?", a: "Helvetica", d: ["Univers", "Futura", "Gill Sans"] },
  { q: "Qui a conçu la police 'Gill Sans' ?", a: "Eric Gill", d: ["Edward Johnston", "Paul Renner", "Adrian Frutiger"] },
  { q: "La typographie 'Baskerville' appartient à quelle famille ?", a: "Transitionnelle", d: ["Humaniste", "Didone", "Mécane"] },
  { q: "Quelle police a été conçue pour les panneaux de signalisation des aéroports de Paris ?", a: "Frutiger", d: ["Univers", "Helvetica", "Avenir"] },
  { q: "Qui a créé la police 'Garamond' au XVIe siècle ?", a: "Claude Garamont", d: ["Robert Estienne", "Geoffroy Tory", "Nicolas Jenson"] },
  { q: "La typographie 'Gotham' a été rendue célèbre par quelle campagne présidentielle ?", a: "Barack Obama 2008", d: ["Donald Trump 2016", "Emmanuel Macron 2017", "John Kennedy 1960"] },
  { q: "Quelle police 'Slab Serif' a été créée pour le journal The Guardian ?", a: "Guardian Egyptian", d: ["Rockwell", "Clarendon", "Courier"] },
  { q: "Qui a conçu la police 'Avenir' ?", a: "Adrian Frutiger", d: ["Max Bill", "Erik Spiekermann", "Hermann Zapf"] },
  { q: "La typographie 'Optima' est une création de...", a: "Hermann Zapf", d: ["Paul Renner", "Adrian Frutiger", "Jan Tschichold"] },
  { q: "Quelle police a été conçue par Matthew Carter pour être lisible sur écran à petite taille ?", a: "Verdana", d: ["Arial", "Georgia", "Tahoma"] },
  { q: "Qui a conçu la police 'Comic Sans' ?", a: "Vincent Connare", d: ["Erik Spiekermann", "Robert Slimbach", "Jonathan Hoefler"] },
  { q: "La police 'Bodoni' se caractérise par un fort contraste entre pleins et déliés. C'est une...", a: "Didone", d: ["Garalde", "Réale", "Linéale"] },
  { q: "Quelle police a été créée pour le métro de Londres en 1916 ?", a: "Johnston", d: ["Gill Sans", "Helvetica", "Futura"] },
  { q: "Qui a conçu la police 'DIN 1451' utilisée sur les routes allemandes ?", a: "Comité DIN", d: ["Paul Renner", "Max Miedinger", "Adrian Frutiger"] },
  { q: "La police 'Sabon' est une version moderne de Garamond créée par...", a: "Jan Tschichold", d: ["Paul Renner", "Hermann Zapf", "Robert Slimbach"] }
])

# --- 12. LE DESIGN INDUSTRIEL ET L'ÉCOLE D'ULM ---
create_quiz("Le Design Industriel et l'École d'Ulm", "Objet", [
  { q: "En quelle année l'École d'Ulm (HfG Ulm) a-t-elle été fondée ?", a: "1953", d: ["1919", "1945", "1968"] },
  { q: "Qui a été le premier recteur de l'École d'Ulm ?", a: "Max Bill", d: ["Tomas Maldonado", "Otl Aicher", "Dieter Rams"] },
  { q: "Quel designer est célèbre pour son travail chez Braun ?", a: "Dieter Rams", d: ["Richard Sapper", "Jonathan Ive", "Konstantin Grcic"] },
  { q: "Combien de 'principes pour un bon design' Dieter Rams a-t-il énoncés ?", a: "10", d: ["5", "12", "7"] },
  { q: "L'École d'Ulm a collaboré étroitement avec quelle entreprise ?", a: "Braun", d: ["Siemens", "Volkswagen", "Lufthansa"] },
  { q: "Le 'Tabouret d'Ulm' (Ulm Stool) a été conçu par Max Bill et...", a: "Hans Gugelot", d: ["Otl Aicher", "Dieter Rams", "Herbert Ohl"] },
  { q: "Qui a conçu l'identité visuelle des JO de Munich 1972 ?", a: "Otl Aicher", d: ["Max Bill", "Herbert Bayer", "Lance Wyman"] },
  { q: "La radio 'Snow White's Coffin' (SK4) est l'œuvre de Dieter Rams et...", a: "Hans Gugelot", d: ["Max Bill", "Richard Sapper", "Otl Aicher"] },
  { q: "Quel est le dernier principe de Dieter Rams ?", a: "Good design is as little design as possible", d: ["Good design is environmentally friendly", "Good design is honest", "Good design is innovative"] },
  { q: "L'École d'Ulm a fermé ses portes en...", a: "1968", d: ["1953", "1933", "1975"] },
  { q: "Le style d'Ulm se caractérise par une approche...", a: "Scientifique et rationnelle", d: ["Artistique et expressive", "Décorative et riche", "Radicale et ironique"] },
  { q: "Qui a succédé à Max Bill comme recteur en 1954 ?", a: "Tomas Maldonado", d: ["Hans Gugelot", "Dieter Rams", "Otl Aicher"] },
  { q: "La typographie 'Rotis' a été créée par...", a: "Otl Aicher", d: ["Adrian Frutiger", "Erik Spiekermann", "Max Bill"] },
  { q: "Quel designer contemporain cite Dieter Rams comme son influence majeure ?", a: "Jonathan Ive", d: ["Marc Newson", "Philippe Starck", "Ron Arad"] },
  { q: "Le logo de la Lufthansa a été redessiné à Ulm par...", a: "Otl Aicher", d: ["Max Bill", "Hans Gugelot", "Herbert Bayer"] }
])

# --- 13. LES FEMMES OUBLIÉES DU DESIGN ---
create_quiz("Les Femmes Oubliées du Design", "Objet", [
  { q: "Quelle designer a collaboré avec Le Corbusier sur la chaise longue LC4 ?", a: "Charlotte Perriand", d: ["Eileen Gray", "Ray Eames", "Jeanne Lanvin"] },
  { q: "Qui a conçu la 'Maison en Bord de Mer' E-1027 ?", a: "Eileen Gray", d: ["Charlotte Perriand", "Lilly Reich", "Gae Aulenti"] },
  { q: "Quel était le rôle de Ray Eames au sein du couple ?", a: "Artiste et théoricienne de la couleur", d: ["Ingénieure structurelle", "Commerciale", "Secrétaire"] },
  { q: "Lilly Reich a collaboré avec quel architecte sur le Pavillon de Barcelone ?", a: "Mies van der Rohe", d: ["Walter Gropius", "Le Corbusier", "Marcel Breuer"] },
  { q: "Quelle designer a créé la lampe 'Pipistrello' ?", a: "Gae Aulenti", d: ["Cini Boeri", "Paola Navone", "Patricia Urquiola"] },
  { q: "Qui a conçu le mobilier de la Villa Savoye avec Le Corbusier ?", a: "Charlotte Perriand", d: ["Andrée Putman", "Florence Knoll", "Aino Aalto"] },
  { q: "Quelle designer a fondé le studio 'Neri & Hu' avec Lyndon Neri ?", a: "Rossana Hu", d: ["Zaha Hadid", "Kazuyo Sejima", "Maya Lin"] },
  { q: "Qui a été la première femme à diriger un atelier au Bauhaus ?", a: "Gunta Stölzl", d: ["Marianne Brandt", "Anni Albers", "Gertrud Arndt"] },
  { q: "Quelle designer est célèbre pour ses créations en textile au Bauhaus ?", a: "Anni Albers", d: ["Gunta Stölzl", "Otti Berger", "Benita Koch-Otte"] },
  { q: "Qui a conçu la table 'E-1027' réglable en hauteur ?", a: "Eileen Gray", d: ["Charlotte Perriand", "Nanna Ditzel", "Grete Jalk"] },
  { q: "Quelle designer a revitalisé la marque Alessi dans les années 80 ?", a: "Aucune (c'est Alberto Alessi)", d: ["Gae Aulenti", "Patricia Urquiola", "Cini Boeri"] },
  { q: "Qui a conçu le musée d'Orsay ?", a: "Gae Aulenti (aménagement)", d: ["Zaha Hadid", "Odile Decq", "Jeanne Gang"] },
  { q: "Quelle designer a créé la chaise 'Trinidad' ?", a: "Nanna Ditzel", d: ["Grete Jalk", "Charlotte Perriand", "Eileen Gray"] },
  { q: "Qui a conçu la 'Tulip Chair' avec Eero Saarinen ? (Question piège)", a: "Personne (il l'a conçue seul)", d: ["Florence Knoll", "Ray Eames", "Aino Aalto"] },
  { q: "Quelle designer a fondé Knoll Associates avec Hans Knoll ?", a: "Florence Knoll", d: ["Ray Eames", "Jeanne Knoll", "Mies van der Rohe"] },
  { q: "Qui a conçu le 'Stool 60' avec Alvar Aalto ?", a: "Aino Aalto", d: ["Loja Saarinen", "Maija Isola", "Vuokko Eskolin-Nurmesniemi"] },
  { q: "Quelle designer est à l'origine des motifs de Marimekko dans les années 60 ?", a: "Maija Isola", d: ["Annika Rimala", "Vuokko Nurmesniemi", "Armi Ratia"] },
  { q: "Qui a conçu la 'Bibendum Chair' ?", a: "Eileen Gray", d: ["Charlotte Perriand", "Lilly Reich", "Gae Aulenti"] },
  { q: "Quelle architecte a conçu le High Museum of Art à Atlanta ?", a: "Zaha Hadid (pour un bâtiment récent)", d: ["Odile Decq", "Kazuyo Sejima", "Renzo Piano"] },
  { q: "Qui a été la première femme à recevoir la médaille d'or du RIBA ?", a: "Zaha Hadid", d: ["Ray Eames", "Charlotte Perriand", "Jane Drew"] }
])

# --- 14. LE MOBILIER EN TUBE D'ACIER ---
create_quiz("Le Mobilier en Tube d'Acier", "Objet", [
  { q: "Qui a conçu la chaise 'Wassily' ?", a: "Marcel Breuer", d: ["Mies van der Rohe", "Le Corbusier", "Mart Stam"] },
  { q: "Quelle chaise est considérée comme la première chaise cantilever (en porte-à-faux) ?", a: "S 33 de Mart Stam", d: ["B32 de Breuer", "MR10 de Mies", "LC1 de Le Corbusier"] },
  { q: "Quel est le nom de la chaise cantilever de Mies van der Rohe ?", a: "MR10", d: ["S 33", "B32", "Cesca"] },
  { q: "La chaise 'Cesca' (B32) combine le tube d'acier et quel autre matériau ?", a: "Le cannage de rotin", d: ["Le cuir", "Le plastique", "Le bois plein"] },
  { q: "Qui a conçu le fauteuil 'Grand Confort' (LC2) ?", a: "Le Corbusier, P. Jeanneret et C. Perriand", d: ["Mies van der Rohe", "Marcel Breuer", "Jean Prouvé"] },
  { q: "La chaise 'Standard' n'est pas en tube mais en tôle pliée. Qui l'a conçue ?", a: "Jean Prouvé", d: ["Marcel Breuer", "Charlotte Perriand", "Le Corbusier"] },
  { q: "Quelle entreprise est historiquement liée à la production du mobilier en tube d'acier ?", a: "Thonet", d: ["Cassina", "Vitra", "Knoll"] },
  { q: "Le fauteuil 'Barcelona' utilise du tube d'acier.", a: "Faux (acier plat)", d: ["Vrai"] },
  { q: "Qui a conçu le fauteuil 'Transat' ?", a: "Eileen Gray", d: ["Charlotte Perriand", "Marcel Breuer", "Le Corbusier"] },
  { q: "La chaise 'S 32' est une variante de la 'Cesca' éditée par...", a: "Thonet", d: ["Cassina", "Knoll", "Vitra"] },
  { q: "Quel designer a créé le fauteuil 'Wassily' alors qu'il était étudiant ?", a: "Marcel Breuer", d: ["Mart Stam", "Herbert Bayer", "Hannes Meyer"] },
  { q: "La chaise 'Landi' en aluminium perforé (1938) est l'œuvre de...", a: "Hans Coray", d: ["Jean Prouvé", "Marcel Breuer", "Le Corbusier"] },
  { q: "Qui a conçu la chaise 'Sandows' en sandows ?", a: "René Herbst", d: ["Robert Mallet-Stevens", "Francis Jourdain", "Pierre Chareau"] },
  { q: "Le fauteuil 'B301' (Basculant) est l'œuvre de...", a: "Le Corbusier, Jeanneret, Perriand", d: ["Marcel Breuer", "Mies van der Rohe", "Mart Stam"] },
  { q: "Quelle designer a dit : 'Le métal joue le même rôle pour le mobilier que le béton pour l'architecture' ?", a: "Charlotte Perriand", d: ["Eileen Gray", "Lilly Reich", "Ray Eames"] }
])

# --- 15. GRAND QUIZ OMNISCIENT DESIGN ---
create_quiz("Grand Quiz Omniscient Design", "Objet", [
  { q: "Quelle école d'art a révolutionné le design moderne en Allemagne ?", a: "Le Bauhaus", d: ["L'Ulm HfG", "Vkhutemas", "Black Mountain College"] },
  { q: "Quel designer a créé la 'Panton Chair' ?", a: "Verner Panton", d: ["Arne Jacobsen", "Hans Wegner", "Eero Saarinen"] },
  { q: "Qui a conçu la Villa Savoye ?", a: "Le Corbusier", d: ["Mies van der Rohe", "Frank Lloyd Wright", "Gropius"] },
  { q: "Quel mouvement a été fondé par Ettore Sottsass ?", a: "Memphis", d: ["Alchimia", "Bauhaus", "De Stijl"] },
  { q: "Qui est le créateur du logo 'I Love NY' ?", a: "Milton Glaser", d: ["Saul Bass", "Paul Rand", "Vignelli"] },
  { q: "Quelle typographie a été créée en 1957 à la fonderie Haas ?", a: "Helvetica", d: ["Futura", "Times", "Arial"] },
  { q: "Qui a conçu le presse-agrume 'Juicy Salif' ?", a: "Philippe Starck", d: ["Jasper Morrison", "Marc Newson", "Ross Lovegrove"] },
  { q: "Quel designer américain a créé le 'Marshmallow Sofa' ?", a: "George Nelson", d: ["Charles Eames", "Eero Saarinen", "Isamu Noguchi"] },
  { q: "Qui a conçu le Pavillon de Barcelone ?", a: "Mies van der Rohe", d: ["Le Corbusier", "Gropius", "Aalto"] },
  { q: "Quel designer italien a créé la lampe 'Arco' ?", a: "Achille Castiglioni", d: ["Sottsass", "Colombo", "Magistretti"] },
  { q: "Quelle designer a collaboré avec Le Corbusier sur les meubles LC ?", a: "Charlotte Perriand", d: ["Eileen Gray", "Ray Eames", "Lilly Reich"] },
  { q: "Qui a conçu la chaise 'Tulip' ?", a: "Eero Saarinen", d: ["Eero Aarnio", "Hans Wegner", "Charles Eames"] },
  { q: "Quel graphiste a créé les génériques de Vertigo et Psycho ?", a: "Saul Bass", d: ["Milton Glaser", "Paul Rand", "Paula Scher"] },
  { q: "Qui a conçu l'horloge 'Ball Clock' ?", a: "George Nelson", d: ["Isamu Noguchi", "Alexander Girard", "Charles Eames"] },
  { q: "Quel designer a créé la 'Wiggle Side Chair' en carton ?", a: "Frank Gehry", d: ["Ron Arad", "Marc Newson", "Tom Dixon"] },
  { q: "Qui a conçu la lampe 'Pipistrello' ?", a: "Gae Aulenti", d: ["Patricia Urquiola", "Paola Navone", "Cini Boeri"] },
  { q: "Quel mouvement est né à Florence en 1966 ?", a: "Radical Design", d: ["Futurisme", "Arte Povera", "Transavantgarde"] },
  { q: "Qui a conçu la chaise 'Wishbone' ?", a: "Hans Wegner", d: ["Arne Jacobsen", "Finn Juhl", "Børge Mogensen"] },
  { q: "Quel designer a créé le luminaire 'Artichoke' ?", a: "Poul Henningsen", d: ["Verner Panton", "Louis Poulsen", "Arne Jacobsen"] },
  { q: "Qui a conçu le terminal TWA à JFK ?", a: "Eero Saarinen", d: ["Frank Lloyd Wright", "Mies van der Rohe", "Le Corbusier"] },
  { q: "Quel designer a créé la 'Ball Chair' ?", a: "Eero Aarnio", d: ["Verner Panton", "Joe Colombo", "Eero Saarinen"] },
  { q: "Qui a conçu la machine à écrire 'Valentine' ?", a: "Ettore Sottsass", d: ["Mario Bellini", "Marcello Nizzoli", "Richard Sapper"] },
  { q: "Quelle designer a conçu la 'Maison de Verre' avec Bijvoet ?", a: "Pierre Chareau", d: ["Eileen Gray", "Charlotte Perriand", "Lilly Reich"] },
  { q: "Qui a conçu le Guggenheim de Bilbao ?", a: "Frank Gehry", d: ["Zaha Hadid", "Jean Nouvel", "Norman Foster"] },
  { q: "Quel designer a créé la lampe 'Tolomeo' ?", a: "Michele De Lucchi", d: ["Achille Castiglioni", "Richard Sapper", "Enzo Mari"] },
  { q: "Qui a conçu le fauteuil 'Up5' ?", a: "Gaetano Pesce", d: ["Joe Colombo", "Ettore Sottsass", "Marco Zanuso"] },
  { q: "Quel graphiste a conçu le logo d'IBM ?", a: "Paul Rand", d: ["Saul Bass", "Massimo Vignelli", "Milton Glaser"] },
  { q: "Qui a conçu la chaise 'Egg' ?", a: "Arne Jacobsen", d: ["Hans Wegner", "Finn Juhl", "Poul Kjærholm"] },
  { q: "Quel designer a créé le tabouret 'Stool 60' ?", a: "Alvar Aalto", d: ["Eero Saarinen", "Hans Wegner", "Arne Jacobsen"] },
  { q: "Qui a conçu la maison 'E-1027' ?", a: "Eileen Gray", d: ["Charlotte Perriand", "Le Corbusier", "Jeanne Lanvin"] },
  { q: "Quel designer a créé le luminaire 'Taccia' ?", a: "Achille Castiglioni", d: ["Vico Magistretti", "Gino Sarfatti", "Joe Colombo"] },
  { q: "Qui a conçu le stade de Pékin en 2008 ?", a: "Herzog & de Meuron", d: ["Zaha Hadid", "Norman Foster", "OMA"] },
  { q: "Quel designer a créé la chaise 'Diamond' ?", a: "Harry Bertoia", d: ["Charles Eames", "Eero Saarinen", "George Nelson"] },
  { q: "Qui a conçu le Musée d'Orsay ?", a: "Gae Aulenti", d: ["Odile Decq", "Zaha Hadid", "Renzo Piano"] },
  { q: "Quel mouvement de design a utilisé le stratifié ?", a: "Memphis", d: ["Bauhaus", "De Stijl", "Art Déco"] },
  { q: "Qui a conçu l'identité visuelle de Mexico 68 ?", a: "Lance Wyman", d: ["Otl Aicher", "Paul Rand", "Saul Bass"] },
  { q: "Quel designer a créé le fauteuil 'Proust' ?", a: "Alessandro Mendini", d: ["Ettore Sottsass", "Gaetano Pesce", "Enzo Mari"] },
  { q: "Qui a conçu la Villa Tugendhat ?", a: "Mies van der Rohe", d: ["Le Corbusier", "Walter Gropius", "Adolf Loos"] },
  { q: "Quel designer a créé la lampe 'Pipistrello' ?", a: "Gae Aulenti", d: ["Paola Navone", "Patricia Urquiola", "Cini Boeri"] },
  { q: "Qui a conçu le logo I Love NY ?", a: "Milton Glaser", d: ["Paul Rand", "Saul Bass", "Vignelli"] },
  { q: "Quel designer a créé la chaise 'Tulip' ?", a: "Eero Saarinen", d: ["Hans Wegner", "Charles Eames", "Eero Aarnio"] },
  { q: "Qui a conçu le bâtiment de la Fondation Louis Vuitton ?", a: "Frank Gehry", d: ["Zaha Hadid", "Jean Nouvel", "Norman Foster"] },
  { q: "Quel designer a créé la machine à écrire 'Valentine' ?", a: "Ettore Sottsass", d: ["Mario Bellini", "Marcello Nizzoli", "Richard Sapper"] },
  { q: "Qui a conçu la 'Petite Robe Noire' ?", a: "Coco Chanel", d: ["Christian Dior", "YSL", "Elsa Schiaparelli"] },
  { q: "Quel designer a créé le presse-agrume 'Juicy Salif' ?", a: "Philippe Starck", d: ["Jasper Morrison", "Marc Newson", "Ross Lovegrove"] },
  { q: "Qui a conçu la lampe 'Arco' ?", a: "Achille Castiglioni", d: ["Joe Colombo", "Vico Magistretti", "Ettore Sottsass"] },
  { q: "Quel designer a créé la chaise 'Egg' ?", a: "Arne Jacobsen", d: ["Hans Wegner", "Verner Panton", "Finn Juhl"] },
  { q: "Qui a conçu le Pavillon de Barcelone ?", a: "Mies van der Rohe", d: ["Le Corbusier", "Walter Gropius", "Alvar Aalto"] },
  { q: "Quel designer a créé la 'Panton Chair' ?", a: "Verner Panton", d: ["Arne Jacobsen", "Hans Wegner", "Eero Saarinen"] },
  { q: "Qui a conçu la Villa Savoye ?", a: "Le Corbusier", d: ["Mies van der Rohe", "Frank Lloyd Wright", "Walter Gropius"] }
])

puts "--- Fin de la génération des quiz ---"
