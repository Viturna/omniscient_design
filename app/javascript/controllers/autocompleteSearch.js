document.addEventListener("DOMContentLoaded", function () {
  const searchField = document.getElementById("workSearch");
  const suggestionsBox = document.createElement("div");
  suggestionsBox.classList.add("suggestions-box");
  searchField.parentElement.appendChild(suggestionsBox);

  searchField.addEventListener("keyup", function () {
    const query = searchField.value.trim();

    if (query.length > 2) {
      fetch(`/search_autocomplete?query=${query}`)
        .then((response) => {
          if (!response.ok) throw new Error("Erreur serveur");
          const contentType = response.headers.get("content-type");
          if (!contentType || !contentType.includes("application/json")) {
            throw new Error("Réponse invalide : pas du JSON");
          }
          return response.json();
        })
        .then((data) => {
          suggestionsBox.innerHTML = ""; // Réinitialise les suggestions

          const createSection = (sectionData) => {
            if (!sectionData || sectionData.results.length === 0) return;

            const section = document.createElement("div");
            const title = document.createElement("p");
            title.classList.add(sectionData.class);
            title.textContent = sectionData.title;
            section.appendChild(title);

            sectionData.results.forEach((item) => {
              const suggestionElement = document.createElement("div");
              suggestionElement.classList.add("suggestion-item");

              if (item.svg) {
                const imgElement = document.createElement("img");
                imgElement.src = item.svg;
                imgElement.classList.add("svg-icon");
                suggestionElement.appendChild(imgElement);
              }

              if (item.img) {
                const imgElement = document.createElement("img");
                imgElement.src = item.img;
                imgElement.alt = item.name;
                imgElement.classList.add("search-img");
                suggestionElement.appendChild(imgElement);
              }

              const textElement = document.createElement("span");
              textElement.textContent = item.name;
              suggestionElement.appendChild(textElement);

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

          createSection(data.domaines);
          createSection(data.designers);
          createSection(data.oeuvres);

          if (
            (!data.designers || data.designers.results.length === 0) &&
            (!data.oeuvres || data.oeuvres.results.length === 0) &&
            (!data.domaines || data.domaines.results.length === 0)
          ) {
            suggestionsBox.innerHTML = "<div class='no-suggestion'>Aucune suggestion</div>";
          }
        })
        .catch((error) => {
          console.error("Erreur AJAX :", error);
          suggestionsBox.innerHTML = "<div class='error-msg'>Erreur lors de la recherche</div>";
        });

    } else {
      suggestionsBox.innerHTML = ""; // Effacer si la requête est trop courte
    }
  });
});
