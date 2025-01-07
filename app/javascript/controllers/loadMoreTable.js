document.addEventListener('DOMContentLoaded', function () {
  // Fonction pour afficher plus de lignes pour un tableau spécifique
  function showMoreRows(rows, loadMoreButton) {
    const initialRowsToShow = 10;
    let rowsToShow = initialRowsToShow;

    // Cacher les lignes supplémentaires initialement
    rows.forEach((row, index) => {
      if (index >= rowsToShow) {
        row.style.display = 'none';
      }
    });

    loadMoreButton.addEventListener('click', function () {
      for (let i = rowsToShow; i < rowsToShow + initialRowsToShow; i++) {
        if (i >= rows.length) {
          loadMoreButton.disabled = true;
          loadMoreButton.textContent = "Toutes les lignes sont chargées";
          break;
        }
        rows[i].style.display = '';
      }
      rowsToShow += initialRowsToShow;
    });
  }

  // Récupérer tous les tableaux et les boutons "Voir plus"
  const tables = document.querySelectorAll('.grid-1 table');
  const loadMoreButtons = document.querySelectorAll('[id^="load-more-button"]');

  // Pour chaque tableau, appliquer la fonction showMoreRows
  tables.forEach((table, index) => {
    const rows = table.querySelectorAll('tbody tr');
    const loadMoreButton = loadMoreButtons[index];
    showMoreRows(rows, loadMoreButton);
  });
});
