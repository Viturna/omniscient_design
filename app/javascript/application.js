import { Turbo } from "@hotwired/turbo-rails";
import Rails from "@rails/ujs"; // Assurez-vous d'utiliser la bonne syntaxe
import "controllers";
import $ from "jquery";

// Assurez-vous que jQuery est accessible globalement
window.$ = $;

// Initialisation des modules
Rails.start();
Turbo.start();

// Code pour la gestion des champs dynamiques
document.addEventListener('click', function(event) {
  if (event.target.matches('.add_fields')) {
    event.preventDefault(); // Assurez-vous que le preventDefault est utilisé correctement
    var time = new Date().getTime();
    var link = event.target;
    var id = link.dataset.id;
    var regexp = new RegExp(id, 'g');
    var new_fields = link.dataset.fields.replace(regexp, time);
    link.insertAdjacentHTML('beforebegin', new_fields);
  }
}, { passive: false }); // Ajoutez cette option pour les événements non passifs
