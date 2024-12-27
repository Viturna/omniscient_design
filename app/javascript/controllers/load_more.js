document.addEventListener("DOMContentLoaded", () => {
  const loadMoreTrigger = document.getElementById("load-more-trigger");
  const loader = document.getElementById("loader");
  let offset = 10; // On commence après les 10 premières cartes
  let loading = false;

  const loadMoreCards = async (type) => {
    if (loading) return;
    loading = true;
    loader.style.display = 'block'; // Afficher le loader

    const response = await fetch(`/${type}/load_more?offset=${offset}`, {
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

    loader.style.display = 'none'; // Masquer le loader
    loading = false;
  };

  const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      const type = loadMoreTrigger.getAttribute("data-type");
      loadMoreCards(type);
    }
  });

  observer.observe(loadMoreTrigger);
});
