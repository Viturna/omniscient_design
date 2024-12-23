$(document).ready(function () {
  let $cards = $(".card");
  const $container = $("#cardContainer");
  let currentIndex = 0; // Index de la carte visible
  let touchStartY = 0; // Position Y initiale pour le touch
  let touchEndY = 0;   // Position Y finale pour le touch

  // Fonction pour aller à une carte spécifique
  function goToCard(index) {
    if (index < 0 || index >= $cards.length) return;

    const $targetCard = $cards.eq(index);
    const scrollTop = $targetCard.position().top + $container.scrollTop();

    $container.stop().animate({ scrollTop }, 300, "swing"); // Défilement fluide
    currentIndex = index;
  }

  // Fonction pour réinitialiser les références aux cartes
  function updateCards() {
    $cards = $(".card");
  }

  // Navigation avec les flèches (desktop uniquement)
  $(document).on("keydown", function (e) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      goToCard(currentIndex + 1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      goToCard(currentIndex - 1);
    }
  });

  // Navigation avec la molette (desktop)
  let scrollTimeout;
  $container.on("wheel", function (e) {
    e.preventDefault();

    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
      if (e.originalEvent.deltaY > 0) {
        goToCard(currentIndex + 1); // Scroll vers le bas
      } else {
        goToCard(currentIndex - 1); // Scroll vers le haut
      }
    }, 50);
  });

  // Navigation avec le tactile (mobile)
  $container.on("touchstart", function (e) {
    touchStartY = e.originalEvent.touches[0].clientY;
  });

  $container.on("touchmove", function (e) {
    touchEndY = e.originalEvent.touches[0].clientY;
  });

  $container.on("touchend", function () {
    const deltaY = touchStartY - touchEndY;

    if (Math.abs(deltaY) > 20) { // Seuil pour détecter un "swipe"
      if (deltaY > 0) {
        goToCard(currentIndex + 1); // Swipe vers le haut
      } else {
        goToCard(currentIndex - 1); // Swipe vers le bas
      }
    }
  });

  // Navigation avec les boutons
  $(".arrow-button.up").on("click", function () {
    goToCard(currentIndex - 1);
  });

  $(".arrow-button.down").on("click", function () {
    goToCard(currentIndex + 1);
  });

  // Réinitialiser les cartes après un "load more"
  document.addEventListener("cardsLoaded", updateCards);

  // Initialisation : aller à la première carte
  goToCard(currentIndex);
});
