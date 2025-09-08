SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.default_host = "https://omniscientdesign.fr"

SitemapGenerator::Sitemap.create do
  # Pages statiques utiles pour SEO
  add '/', priority: 1.0, changefreq: 'daily'
  add '/presentation', priority: 0.7, changefreq: 'monthly'
  add '/add_elements', priority: 0.7, changefreq: 'monthly'
  add '/parrainage', priority: 0.5, changefreq: 'monthly'
  add '/mentionslegales', priority: 0.5, changefreq: 'monthly'
  add '/cookies', priority: 0.5, changefreq: 'monthly'
  add '/politiquedeconfidentialite', priority: 0.5, changefreq: 'monthly'
  add '/cgu', priority: 0.5, changefreq: 'monthly'
  add '/changelog', priority: 0.5, changefreq: 'monthly'
  add '/search'priority: 0.7, changefreq: 'monthly'
  add '/contributions', priority: 0.5, changefreq: 'monthly'

  # Page de connexion
  add '/users/sign_in'priority: 0.8, changefreq: 'monthly'

  # Designers dynamiques
  Designer.find_each do |designer|
    add designer_path(designer), lastmod: designer.updated_at, priority: 0.8, changefreq: 'weekly'
  end

  # Œuvres dynamiques
  Oeuvre.find_each do |oeuvre|
    add oeuvre_path(oeuvre), lastmod: oeuvre.updated_at, priority: 0.8, changefreq: 'weekly'
  end
end
