import { Turbo } from "@hotwired/turbo-rails";
import "controllers";
import $ from "jquery";
import Rails from "@rails/ujs";
import "stylesheets/application.scss";

Rails.start();
window.$ = $; // Assure la disponibilité globale de jQuery

// Démarre Turbo après Rails UJS
Turbo.start();

// Code pour la gestion des champs dynamiques
document.addEventListener('turbo:load', () => {
  // Gestion des événements dynamiques (Turbo remplace 'DOMContentLoaded')
  document.addEventListener('click', function(event) {
    if (event.target.matches('.add_fields')) {
      event.preventDefault();
      const time = new Date().getTime();
      const link = event.target;
      const id = link.dataset.id;
      const regexp = new RegExp(id, 'g');
      const new_fields = link.dataset.fields.replace(regexp, time);
      link.insertAdjacentHTML('beforebegin', new_fields);
    }
  }, { passive: false });
});
