module ApplicationHelper
  def should_not_index?
    # Liste des contrôleurs et actions que tu ne veux pas indexer
    no_index_pages = [
      { controller: 'lists', action: 'create' },
      { controller: 'lists', action: 'show' },
      { controller: 'lists', action: 'edit' },
      { controller: 'oeuvres', action: 'edit' },
      { controller: 'designers', action: 'edit' },
      { controller: 'feedbacks', action: 'new' },
      { controller: 'notifications', action: 'index' }
    ]

    # Vérifie si la page actuelle correspond à l'une des pages dans la liste
    no_index_pages.any? do |page|
      controller_name == page[:controller] && action_name == page[:action]
    end
  end

  def show_footer?
    excluded_pages = [
      {controller: 'lists',      actions: %w[show edit index new]},
      {controller: 'oeuvres',    actions: %w[index new edit]},
      {controller: 'designers',  actions: %w[index new edit]},
      {controller: 'studios',  actions: %w[index new edit]},
      {controller: 'pages',      actions: %w[add_elements]},
      {controller: 'feedbacks',  actions: %w[new]},
      {controller: 'notifications',  actions: %w[index]},
      {controller: 'registrations',  actions: %w[new edit]},
      {controller: 'passwords',  actions: %w[new edit]},
      {controller: 'confirmations',  actions: %w[new]},
      {controller: 'sessions',  actions: %w[new]}
    ]
    !excluded_pages.any? { |p| p[:controller] == controller_name && p[:actions].include?(action_name) }
  end

def ads_data
  ads_from_db = Ad.currently_active.with_attached_image.with_attached_image_mobile

  ads_from_db.map do |ad|
    mobile_url = ad.image_mobile.attached? ? url_for(ad.image_mobile) : url_for(ad.image)
    desktop_url = ad.image.attached? ? url_for(ad.image) : nil

    {
      id: ad.id,
      link: ad.link,
      image_desktop_url: desktop_url,
      image_mobile_url: mobile_url,
      title: ad.title,
      description: ad.description
    }
  end
end
  
  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.assets.find_asset(path).present?
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end


  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def remove_accents_and_special_chars(str)
    return '' if str.nil?
  
    normalized_str = str.gsub(/[ÀÁÂÃÄÅ]/, 'A')
                        .gsub(/[àáâãäå]/, 'a')
                        .gsub(/[ÒÓÔÕÖØōòóôõöø]/, 'O')
                        .gsub(/[ÈÉÊË]/, 'E')
                        .gsub(/[èéêë]/, 'e')
                        .gsub(/[Çç]/, 'c')
                        .gsub(/[Ð]/, 'D')
                        .gsub(/[ÌÍÎÏ]/, 'I')
                        .gsub(/[ìíîï]/, 'i')
                        .gsub(/[ÙÚÛÜ]/, 'U')
                        .gsub(/[ùúûü]/, 'u')
                        .gsub(/[Ññ]/, 'N')
                        .gsub(/[Šš]/, 'S')
                        .gsub(/[Ÿÿý]/, 'Y')
                        .gsub(/[Žž]/, 'Z')
                        .gsub(/[œ]/, 'oe')
                        .gsub(/[Œ]/, 'OE')
                        .gsub(/[\(\)\"\,.!&“”']/, '') 
                        .gsub('/', '_') 
                        .gsub('\'', '_')             
                        .gsub(' ', '_')              
                        .downcase
  
    normalized_str
  end
  
  def linkify_designer_names_and_oeuvres(text)
    return "" if text.blank?

    lists = Rails.cache.fetch("linkify_keywords_list", expires_in: 12.hours) do
      {
        designers: Designer.where(validation: true)
                           .select(:id, :prenom, :nom, :slug)
                           .map { |d| { name: "#{d.prenom} #{d.nom}".strip, slug: d.slug } },
                           
        studios: Studio.where(validation: true)
                       .select(:id, :nom, :slug)
                       .map { |s| { name: s.nom, slug: s.slug } },
                       
        oeuvres: Oeuvre.where(validation: true)
                       .select(:id, :nom_oeuvre, :slug)
                       .map { |o| { name: o.nom_oeuvre, slug: o.slug } }
      }
    end
    lists[:designers].each do |item|
      next if item[:name].blank?
      
      regex = Regexp.new("\\b#{Regexp.escape(item[:name])}\\b")
      
      text = text.gsub(regex) do |match|
        "<a class=\"black underline\" href='/designers/#{item[:slug]}'>#{match}</a>"
      end
    end

    lists[:studios].each do |item|
      next if item[:name].blank?

      regex = Regexp.new("\\b#{Regexp.escape(item[:name])}\\b")
      
      text = text.gsub(regex) do |match|
        "<a class=\"black underline\" href='/studios/#{item[:slug]}'>#{match}</a>"
      end
    end

    lists[:oeuvres].each do |item|
      next if item[:name].blank?

      regex = Regexp.new("\\b#{Regexp.escape(item[:name])}\\b")
      
      text = text.gsub(regex) do |match|
        "<a class=\"black underline\" href='/oeuvres/#{item[:slug]}'>#{match}</a>"
      end
    end

    text.html_safe
  end
  def oui_non(value)
    value ? "Oui" : "Non"
  end
  def current_theme
    cookies&.[](:theme).presence || 'system'
  end
end