// app/javascript/controllers/load_more.js

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
});