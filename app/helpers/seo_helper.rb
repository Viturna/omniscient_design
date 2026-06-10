module SeoHelper
  def json_ld_designer(designer)
    hash = {
      "@context" => "https://schema.org",
      "@type" => "Person",
      "name" => "#{designer.prenom} #{designer.nom}".strip,
      "description" => truncate(designer.presentation_generale.to_s, length: 300),
      "jobTitle" => "Designer",
      "url" => designer_url(designer)
    }
    hash["image"] = url_for(designer.designer_images.first.file) if designer.designer_images.first&.file&.attached?
    hash["birthDate"] = designer.date_naissance.to_s if designer.date_naissance.present?
    hash["deathDate"] = designer.date_deces.to_s if designer.date_deces.present?
    
    hash.to_json.html_safe
  end

  def json_ld_reference(reference)
    hash = {
      "@context" => "https://schema.org",
      "@type" => "VisualArtwork",
      "name" => reference.nom_reference,
      "description" => truncate(reference.presentation_generale.to_s, length: 300),
      "url" => reference_url(reference)
    }
    hash["image"] = url_for(reference.reference_images.first.file) if reference.reference_images.first&.file&.attached?
    hash["dateCreated"] = reference.date_reference.to_s if reference.date_reference.present?
    
    if reference.designers.any?
      hash["creator"] = reference.designers.map do |designer|
        {
          "@type" => "Person",
          "name" => "#{designer.prenom} #{designer.nom}".strip,
          "url" => designer_url(designer)
        }
      end
    end
    
    hash.to_json.html_safe
  end

  def json_ld_studio(studio)
    hash = {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => studio.nom,
      "description" => truncate(studio.presentation_generale.to_s, length: 300),
      "url" => studio_url(studio)
    }
    hash["image"] = url_for(studio.studio_images.first.file) if studio.studio_images.first&.file&.attached?
    hash["foundingDate"] = studio.date_creation.to_s if studio.date_creation.present?
    hash["dissolutionDate"] = studio.date_fin.to_s if studio.date_fin.present?
    
    hash.to_json.html_safe
  end
end
