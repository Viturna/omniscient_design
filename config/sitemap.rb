# Fichier : config/sitemap.rb

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.default_host = "https://omniscientdesign.fr"

SitemapGenerator::Sitemap.create do

  # --- PAGES PRINCIPALES (Contenu dynamique & forte priorité) ---

  # Page d'accueil (Oeuvres#index)
  add root_path, priority: 1.0, changefreq: 'daily'

  # Index des Designers
  add designers_path, priority: 0.9, changefreq: 'daily'

  # Frise chronologique
  add frise_oeuvres_path, priority: 0.8, changefreq: 'daily'


  # --- CONTENU DYNAMIQUE (Les "objets" de votre site) ---

  Designer.find_each do |designer|
    add designer_path(designer), lastmod: designer.updated_at, priority: 0.8, changefreq: 'weekly'
  end


  Oeuvre.find_each do |oeuvre|
    add oeuvre_path(oeuvre), lastmod: oeuvre.updated_at, priority: 0.8, changefreq: 'weekly'
  end
  

  # --- PAGES "STATIQUES" (Contenu de présentation) ---

  add presentation_path, priority: 0.7, changefreq: 'monthly'
  add add_elements_path, priority: 0.7, changefreq: 'monthly'
  add parrainage_path, priority: 0.5, changefreq: 'monthly'
  add changelog_path, priority: 0.5, changefreq: 'monthly'
  add kit_presse_path, priority: 0.4, changefreq: 'monthly'
  add plan_site_path, priority: 0.4, changefreq: 'monthly'

  # --- PAGES LÉGALES (Basse priorité) ---
  
  add mentionslegales_path, priority: 0.2, changefreq: 'yearly'
  add cookies_path, priority: 0.2, changefreq: 'yearly'
  add politiquedeconfidentialite_path, priority: 0.2, changefreq: 'yearly'
  add cgu_path, priority: 0.2, changefreq: 'yearly'
  
  
end