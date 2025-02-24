class SearchController < ApplicationController
  def autocomplete
    query = params[:query].to_s.strip

    # Recherche dans Oeuvre, Designer et Domaine avec Searchkick
    @oeuvre_suggestions = Oeuvre.search(query, fields: [:nom_oeuvre], match: :word_start, where: { validation: true })
    @designer_suggestions = Designer.search(query, fields: [:nom, :prenom], match: :word_start, where: { validation: true })
    @domaine_suggestions = Domaine.search(query, fields: [:domaine], match: :word_start)

    # Mapper les résultats
    oeuvre_results = @oeuvre_suggestions.results.map { |oeuvre| 
      { name: oeuvre.nom_oeuvre, url: oeuvre_path(oeuvre) }
    }

    designer_results = @designer_suggestions.results.map { |designer| 
      { name: "#{designer.prenom} #{designer.nom}", url: designer_path(designer) }
    }

    # Utilisation de l'ID du domaine et non du nom
    domaine_results = @domaine_suggestions.results.map { |domaine| 
      { name: domaine.domaine, url: search_category_path(domaine: domaine.id) } # Lien vers la recherche filtrée par ID du domaine
    }

    # Organiser les résultats sous trois sections séparées
    suggestions = {
      designers: {
        title: "Designers",
        class: "section-title", # Classe CSS partagée pour tous les titres
        results: designer_results
        
      },
      oeuvres: {
        title: "Références",
        class: "section-title", # Classe CSS partagée pour tous les titres
        results: oeuvre_results
      },
      domaines: {
        title: "Domaines",
        class: "section-title", # Classe CSS partagée pour tous les titres
        results: domaine_results
      }
    }

    render json: suggestions
  end
end
