# Fichier : config/sitemap.rb

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.default_host = "https://omniscientdesign.fr"

SitemapGenerator::Sitemap.create do

  # --- PAGES PRINCIPALES (Contenu dynamique & forte priorité) ---

  # Page d'accueil par défaut
  add root_path, priority: 1.0, changefreq: 'daily'

  [:fr, :en].each do |locale|
    add root_path(locale: locale), priority: 1.0, changefreq: 'daily'
    add designers_path(locale: locale), priority: 0.9, changefreq: 'daily'
    add frise_references_path(locale: locale), priority: 0.8, changefreq: 'daily'
  end

  # --- CONTENU DYNAMIQUE (Les "objets" de votre site) ---

  Designer.find_each do |designer|
    [:fr, :en].each do |locale|
      add designer_path(slug: designer.slug, locale: locale), lastmod: designer.updated_at, priority: 0.8, changefreq: 'weekly'
    end
  end

  Reference.find_each do |reference|
    [:fr, :en].each do |locale|
      add reference_path(slug: reference.slug, locale: locale), lastmod: reference.updated_at, priority: 0.8, changefreq: 'weekly'
    end
  end
  

  # --- PAGES "STATIQUES" (Contenu de présentation) ---

  [:fr, :en].each do |locale|
    add presentation_path(locale: locale), priority: 0.7, changefreq: 'monthly'
    add add_elements_path(locale: locale), priority: 0.7, changefreq: 'monthly'
    add parrainage_path(locale: locale), priority: 0.5, changefreq: 'monthly'
    add changelog_path(locale: locale), priority: 0.5, changefreq: 'monthly'
    add kit_presse_path(locale: locale), priority: 0.4, changefreq: 'monthly'
    add plan_site_path(locale: locale), priority: 0.4, changefreq: 'monthly'

    # --- PAGES LÉGALES (Basse priorité) ---
    add mentionslegales_path(locale: locale), priority: 0.2, changefreq: 'yearly'
    add cookies_path(locale: locale), priority: 0.2, changefreq: 'yearly'
    add politiquedeconfidentialite_path(locale: locale), priority: 0.2, changefreq: 'yearly'
    add cgu_path(locale: locale), priority: 0.2, changefreq: 'yearly'
  end

end