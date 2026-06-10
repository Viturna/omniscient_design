# Fichier : config/sitemap.rb

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.default_host = 'https://omniscientdesign.fr'

SitemapGenerator::Sitemap.create do
  # --- PAGES PRINCIPALES (Contenu dynamique & forte priorité) ---

  # Page d'accueil par défaut
  add root_path, priority: 1.0, changefreq: 'daily'

  %i[fr en].each do |locale|
    add root_path(locale: locale), priority: 1.0, changefreq: 'daily'
    add designers_path(locale: locale), priority: 0.9, changefreq: 'daily'
    add frise_references_path(locale: locale), priority: 0.8, changefreq: 'daily'
  end

  Designer.find_each do |designer|
    %i[fr en].each do |locale|
      add designer_path(slug: designer.slug, locale: locale), lastmod: designer.updated_at, priority: 0.8,
                                                              changefreq: 'weekly'
    end
  end

  Reference.find_each do |reference|
    %i[fr en].each do |locale|
      add reference_path(slug: reference.slug, locale: locale), lastmod: reference.updated_at, priority: 0.8,
                                                                changefreq: 'weekly'
    end
  end

  
# Studios
%i[fr en].each do |locale|
  add studios_path(locale: locale), priority: 0.9, changefreq: 'weekly'
end

Studio.find_each do |studio|
  %i[fr en].each do |locale|
    add studio_path(slug: studio.slug, locale: locale), lastmod: studio.updated_at, priority: 0.8, changefreq: 'weekly'
  end
end

  
# Quizzes
%i[fr en].each do |locale|
  add quizzes_hub_path(locale: locale), priority: 0.8, changefreq: 'weekly'
end

Quiz.find_each do |quiz|
  %i[fr en].each do |locale|
    add quiz_path(id: quiz.id, locale: locale), lastmod: quiz.updated_at, priority: 0.7, changefreq: 'monthly'
  end
end

  # --- PAGES "STATIQUES" (Contenu de présentation) ---

  %i[fr en].each do |locale|
    add presentation_path(locale: locale), priority: 0.7, changefreq: 'monthly'
    add training_path(locale: locale), priority: 0.7, changefreq: 'monthly'
add ressources_path(locale: locale), priority: 0.7, changefreq: 'monthly'

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
