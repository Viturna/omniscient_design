document.addEventListener("DOMContentLoaded", function () {
  const searchField = document.getElementById('workSearch');
  const suggestionsBox = document.createElement('div');
  suggestionsBox.classList.add('suggestions-box');
  searchField.parentElement.appendChild(suggestionsBox);

  searchField.addEventListener('keyup', function () {
    const query = searchField.value.trim();

    if (query.length > 2) {
      // Envoie la requête AJAX pour chercher les suggestions
      fetch(`/search_autocomplete?query=${query}`)
        .then(response => response.json())
        .then(data => {
          suggestionsBox.innerHTML = ''; // Réinitialise la boîte de suggestions

          // Vérifie si chaque section a des résultats et affiche le titre avec la classe partagée
          if (data.designers.results.length > 0) {
            const designerSection = document.createElement('div');
            const designerTitle = document.createElement('p');
            designerTitle.classList.add(data.designers.class); // Applique la même classe partagée
            designerTitle.textContent = data.designers.title;
            designerSection.appendChild(designerTitle);

            data.designers.results.forEach(item => {
              const suggestionElement = document.createElement('div');
              suggestionElement.classList.add('suggestion-item');
              suggestionElement.textContent = item.name;
              suggestionElement.addEventListener('click', function () {
                window.location.href = item.url;
              });
              designerSection.appendChild(suggestionElement);
            });
            suggestionsBox.appendChild(designerSection);
          }

          if (data.oeuvres.results.length > 0) {
            const oeuvreSection = document.createElement('div');
            const oeuvreTitle = document.createElement('p');
            oeuvreTitle.classList.add(data.oeuvres.class); // Applique la même classe partagée
            oeuvreTitle.textContent = data.oeuvres.title;
            oeuvreSection.appendChild(oeuvreTitle);

            data.oeuvres.results.forEach(item => {
              const suggestionElement = document.createElement('div');
              suggestionElement.classList.add('suggestion-item');
              suggestionElement.textContent = item.name;
              suggestionElement.addEventListener('click', function () {
                window.location.href = item.url;
              });
              oeuvreSection.appendChild(suggestionElement);
            });
            suggestionsBox.appendChild(oeuvreSection);
          }

          if (data.domaines.results.length > 0) {
            const domaineSection = document.createElement('div');
            const domaineTitle = document.createElement('p');
            domaineTitle.classList.add(data.domaines.class); // Applique la même classe partagée
            domaineTitle.textContent = data.domaines.title;
            domaineSection.appendChild(domaineTitle);

            data.domaines.results.forEach(item => {
              const suggestionElement = document.createElement('div');
              suggestionElement.classList.add('suggestion-item');
              suggestionElement.textContent = item.name;
              suggestionElement.addEventListener('click', function () {
                window.location.href = item.url;
              });
              domaineSection.appendChild(suggestionElement);
            });
            suggestionsBox.appendChild(domaineSection);
          }

          if (!data.designers.results.length && !data.oeuvres.results.length && !data.domaines.results.length) {
            suggestionsBox.innerHTML = 'Aucune suggestion';
          }
        })
        .catch(error => {
          console.error("Erreur dans la requête AJAX :", error);
        });
    } else {
      suggestionsBox.innerHTML = ''; // Effacer les suggestions si la requête est trop courte
    }
  });
});
