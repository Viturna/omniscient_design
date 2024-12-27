document.addEventListener("DOMContentLoaded", () => {
  const loadMoreTrigger = document.getElementById("load-more-trigger");
  let offset = 10; // On commence après les 10 premières oeuvres
  let loading = false;

  const loadMoreCards = async () => {
    if (loading) return;
    loading = true;

    const response = await fetch(`/oeuvres/load_more?offset=${offset}`, {
      headers: {
        "X-Requested-With": "XMLHttpRequest",
      },
    });

    if (response.ok) {
      const html = await response.text();
      const boxCard = document.getElementById("boxCard");
      boxCard.insertAdjacentHTML("beforeend", html);
      offset += 10;

      // Déclencher un événement personnalisé après l'insertion des nouvelles cartes
      const event = new CustomEvent("cardsLoaded");
      document.dispatchEvent(event);
    }

    loading = false;
  };

  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      loadMoreCards();
    }
  });

  if (loadMoreTrigger) {
    observer.observe(loadMoreTrigger);
  }

  // Vérification pour les petits écrans
  const isSmallScreen = window.matchMedia("(max-width: 600px)").matches;
  if (isSmallScreen) {
    loadMoreCards();
  }
});
