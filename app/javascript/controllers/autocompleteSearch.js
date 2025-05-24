document.addEventListener("DOMContentLoaded", function () {
  const searchField = document.getElementById("workSearch");
  const suggestionsBox = document.getElementById("autocompleteResults");

  let debounceTimer;

  function debounce(callback, delay) {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(callback, delay);
  }

  searchField.addEventListener("input", function () {
    const query = searchField.value.trim();

    if (query.length <= 2) {
      suggestionsBox.innerHTML = "";
      suggestionsBox.style.display = "none";
      return;
    }

    debounce(() => {
      fetch(`/search_autocomplete?query=${encodeURIComponent(query)}`)
        .then(response => {
          if (!response.ok) throw new Error("Erreur serveur");
          return response.json();
        })
        .then(data => {
          suggestionsBox.innerHTML = "";
          suggestionsBox.style.display = "block";

          const createSection = (sectionData) => {
            if (!sectionData || sectionData.results.length === 0) return;

            const section = document.createElement("div");
            section.classList.add("autocomplete-section");

            const title = document.createElement("p");
            title.classList.add("autocomplete-title");
            title.textContent = sectionData.title;
            section.appendChild(title);

            sectionData.results.forEach((item) => {
              const suggestion = document.createElement("div");
              suggestion.classList.add("suggestion-item");

              if (item.svg || item.img) {
                const img = document.createElement("img");
                img.src = item.svg || item.img;
                img.alt = item.name;
                img.classList.add("suggestion-icon");
                suggestion.appendChild(img);
              }

              const label = document.createElement("div");
              label.classList.add("suggestion-label");
              label.textContent = item.name;
              suggestion.appendChild(label);

              if (item.designer) {
                const designer = document.createElement("small");
                designer.classList.add("suggestion-designer");
                designer.textContent = `Designé par : ${item.designer}`;
                suggestion.appendChild(designer);
              }

              suggestion.addEventListener("click", () => {
                window.location.href = item.url;
              });

              section.appendChild(suggestion);
            });

            suggestionsBox.appendChild(section);
          };

          createSection(data.domaines);
          createSection(data.designers);
          createSection(data.oeuvres);

          if (
            (!data.domaines || data.domaines.results.length === 0) &&
            (!data.designers || data.designers.results.length === 0) &&
            (!data.oeuvres || data.oeuvres.results.length === 0)
          ) {
            suggestionsBox.innerHTML = "<div class='no-suggestion'>Aucune suggestion</div>";
          }
        })
        .catch(error => {
          console.error("Erreur AJAX :", error);
          suggestionsBox.innerHTML = "<div class='error-msg'>Erreur de chargement</div>";
        });
    }, 300); // délai pour éviter les requêtes trop fréquentes
  });

  // Clic en dehors = cacher la box
  document.addEventListener("click", (e) => {
    if (!e.target.closest(".autocomplete")) {
      suggestionsBox.style.display = "none";
    }
  });
});
