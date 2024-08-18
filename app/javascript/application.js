// app/javascript/application.js

// Importation des modules nécessaires
import { Turbo } from "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "controllers";
import $ from 'jquery';

// Assurez-vous que jQuery est accessible globalement
window.$ = $;

// Initialisation des modules
Rails.start();
Turbo.start();

// Si vous utilisez ActiveStorage, assurez-vous qu'il est importé et initialisé correctement
// ActiveStorage.start(); // Assurez-vous que ActiveStorage est importé correctement, sinon commentez cette ligne

// Code pour la gestion des champs dynamiques
document.addEventListener("DOMContentLoaded", function() {
  document.addEventListener('click', function(event) {
    if (event.target.matches('.add_fields')) {
      event.preventDefault();
      var time = new Date().getTime();
      var link = event.target;
      var id = link.dataset.id;
      var regexp = new RegExp(id, 'g');
      var new_fields = link.dataset.fields.replace(regexp, time);
      link.insertAdjacentHTML('beforebegin', new_fields);
    }
  });
});
