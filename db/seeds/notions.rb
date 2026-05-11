puts "Cleaning old notions..."
Notion.destroy_all

notions_data = {
  "Structure & Composition" => [
    "Accumulation & Densité",
    "Articulation & Connexion",
    "Déconstruction & Fragmentation",
    "Échelle & Proportion",
    "Équilibre & Symétrie",
    "Hiérarchie & Stratification",
    "Inclusion & Mise en abyme",
    "Motif & Ornementation",
    "Répétition"
  ],
  "Forme & Matière" => [
    "Couleur & Saturation",
    "Déformation & Distorsion",
    "Dématérialisation",
    "Fluidité & Rigidité",
    "Hybridation & Fusion",
    "Lumière & Ombre",
    "Masse & Légèreté",
    "Minimalisme & Vide",
    "Texture & État de surface",
    "Transparence & Opacité"
  ],
  "Mouvement & Temporalité" => [
    "Ancrage & Élévation",
    "Cinétisme & Vibration",
    "Éphémère & Apparition",
    "Interaction",
    "Mobilité & Déploiement",
    "Mutation & Évolution",
    "Pérennité"
  ],
  "Sens & Message" => [
    "Détournement & Appropriation",
    "Engagement & Sensibilisation",
    "Exagération & Contraste",
    "Illusion & Simulation",
    "Narration & Évocation",
    "Symbole & Archétype"
  ],
  "Démarche & Procédés" => [
    "Artisanat & Savoir-faire",
    "Biomimétisme",
    "Conception collaborative",
    "Ergonomie & Usages",
    "Innovation & Optimisation",
    "Modularité & Standardisation",
    "Rationalisation & Simplification",
    "Réemploi & Réhabilitation"
  ]
}

puts "Creating new notions..."
notions_data.each do |theme, names|
  names.each do |name|
    Notion.create!(theme: theme, name: name)
  end
end

puts "Done! Created #{Notion.count} notions across #{Notion.unique_themes.size} themes."
