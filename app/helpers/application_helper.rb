module ApplicationHelper
  def asset_exists?(path)
    if Rails.application.assets.find_asset(path).present?
      true
    else
      false
    end
  rescue Sprockets::FileNotFound
    false
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
