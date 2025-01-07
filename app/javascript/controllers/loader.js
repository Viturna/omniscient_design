$(document).ready(function() { // Changement de turbolinks:load à turbo:load
  document.getElementById("loading").style.display = "none"; // Masquer le loader
  document.getElementById("content").style.display = "block"; // Afficher le contenu
});

window.addEventListener('load', function() {
  document.getElementById("loading").style.display = "none"; // Masquer le loader
  document.getElementById("content").style.display = "block"; // Afficher le contenu
});
