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

  def asset_exists?(path)
    if Rails.application.assets
      Rails.application.assets.find_asset(path).present?
    else
      Rails.application.assets_manifest.find_sources(path).present?
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
    designers = Designer.where(validation: true)
    oeuvres = Oeuvre.where(validation: true)

    designers.each do |designer|
      nom_complet = "#{designer.prenom} #{designer.nom}"
      next if nom_complet.blank?

      regex = Regexp.new("\\b#{Regexp.escape(nom_complet)}\\b")

      text = text.gsub(regex) do |match|
        "<a class=\"black underline\" href='/designers/#{designer.slug}'>#{match}</a>"
      end
    end

    oeuvres.each do |oeuvre|
      next if oeuvre.nom_oeuvre.blank?

      regex = Regexp.new("\\b#{Regexp.escape(oeuvre.nom_oeuvre)}\\b")

      text = text.gsub(regex) do |match|
        "<a class=\"black underline\" href='/oeuvres/#{oeuvre.slug}'>#{match}</a>"
      end
    end

    text.html_safe
  end
  def current_theme
    cookies[:theme].presence || 'light-mode'
  rescue
    'light-mode'
  end
end