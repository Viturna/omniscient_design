# config/initializers/sitemap.rb
SitemapGenerator::Sitemap.default_host = "https://omniscientdesign.fr"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Pages statiques
  add root_path, priority: 1.0, changefreq: 'daily'
  add search_category_path, priority: 0.7, changefreq: 'monthly'
  add search_frise_path, priority: 0.7, changefreq: 'monthly'
  add parrainage_path, priority: 0.5, changefreq: 'yearly'
  add presentation_path, priority: 0.6, changefreq: 'yearly'
  add add_elements_path, priority: 0.6, changefreq: 'yearly'
  add profil_path, priority: 0.6, changefreq: 'weekly'
  add mentionslegales_path, priority: 0.4, changefreq: 'yearly'
  add politiquedeconfidentialite_path, priority: 0.4, changefreq: 'yearly'
  add cookies_path, priority: 0.4, changefreq: 'yearly'
  add changelog_path, priority: 0.5, changefreq: 'monthly'
  add lists_path, priority: 0.7, changefreq: 'monthly'
  # Routes dynamiques pour les ressources
  Oeuvre.find_each do |oeuvre|
    add oeuvre_path(oeuvre), lastmod: oeuvre.updated_at, priority: 0.8, changefreq: 'weekly'
  end

  Designer.find_each do |designer|
    add designer_path(designer), lastmod: designer.updated_at, priority: 0.8, changefreq: 'weekly'
  end
  # Health check
  add rails_health_check_path, priority: 0.1, changefreq: 'daily'
end
