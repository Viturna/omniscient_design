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
    normalized_str = str.tr(
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØōòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž',
      'AAAAAAaaaaaaOOOOOOoooooooEEEEeeeeecCDIIIIiiiiUUUUuuuuNnSsYyyZz'
    )

    normalized_str
    .gsub(/[\(\)\"\/\,!&“”]/, '')
    .gsub('\'', '_')
    .gsub(' ', '_')
    .downcase
  end
end
