document.addEventListener("DOMContentLoaded", function () {
  const searchField = document.getElementById("workSearch");
  const suggestionsBox = document.createElement("div");
  suggestionsBox.classList.add("suggestions-box");
  searchField.parentElement.appendChild(suggestionsBox);

  searchField.addEventListener("keyup", function () {
    const query = searchField.value.trim();

    if (query.length > 2) {
      fetch(`/search_autocomplete?query=${query}`)
        .then((response) => response.json())
        .then((data) => {
          suggestionsBox.innerHTML = ""; // Réinitialise les suggestions

          // Fonction générique pour créer une section
          const createSection = (sectionData) => {
            if (sectionData.results.length === 0) return;

            const section = document.createElement("div");
            const title = document.createElement("p");
            title.classList.add(sectionData.class);
            title.textContent = sectionData.title;
            section.appendChild(title);

            sectionData.results.forEach((item) => {
              const suggestionElement = document.createElement("div");
              suggestionElement.classList.add("suggestion-item");

              // Ajouter l'image SVG ou l'image si elle est disponible
              if (item.svg) {
                const imgElement = document.createElement("img");
                imgElement.src = item.svg; // URL correcte générée par `asset_path`
                imgElement.classList.add("svg-icon");
                suggestionElement.appendChild(imgElement);
              }

              if (item.img) {
                const imgElement = document.createElement("img");
                imgElement.src = item.img;
                imgElement.alt = item.name;
                imgElement.classList.add("search-img"); // Ajoute une classe CSS pour le style
                suggestionElement.appendChild(imgElement);
              }

              // Afficher le nom de l'élément (Designer ou Oeuvre)
              const textElement = document.createElement("span");
              textElement.textContent = item.name;
              suggestionElement.appendChild(textElement);

              // Si c'est une œuvre, ajouter également le designer
              if (item.designer) {
                const designerElement = document.createElement("span");
                designerElement.classList.add("designer-name");
                designerElement.textContent = `Designé par: ${item.designer}`;
                suggestionElement.appendChild(designerElement);
              }

              suggestionElement.addEventListener("click", function () {
                window.location.href = item.url;
              });

              section.appendChild(suggestionElement);
            });

            suggestionsBox.appendChild(section);
          };

          // Générer les différentes sections (Domaines, Designers, Oeuvres)
          createSection(data.domaines);
          createSection(data.designers);
          createSection(data.oeuvres);

          // Afficher "Aucune suggestion" si aucun résultat
          if (
            !data.designers.results.length &&
            !data.oeuvres.results.length &&
            !data.domaines.results.length
          ) {
            suggestionsBox.innerHTML = "Aucune suggestion";
          }
        })
        .catch((error) => console.error("Erreur AJAX :", error));
    } else {
      suggestionsBox.innerHTML = ""; // Effacer si la requête est trop courte
    }
  });
});
