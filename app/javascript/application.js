// ------------------------
// IMPORTS
// ------------------------
import "@hotwired/turbo-rails"

import "controllers"

// jQuery et plugins
import "jquery"
window.$ = window.jQuery = window.$ || window.jQuery

import "select2"

import "gsap"
import "gsap/ScrollTrigger"


document.addEventListener("turbo:load", function () {

  $(".select2").select2({
    placeholder: "Choisir une option",
    allowClear: true,
    width: "100%",
    language: {
      noResults: function () {
        return "Aucun résultat trouvé";
      },
      searching: function () {
        return "Recherche en cours…";
      },
      inputTooShort: function (args) {
        return "Veuillez entrer au moins " + (args.minimum - args.input.length) + " caractère(s)";
      },
      inputTooLong: function (args) {
        return "Veuillez supprimer " + (args.input.length - args.maximum) + " caractère(s)";
      },
      maximumSelected: function (args) {
        return "Vous pouvez seulement sélectionner " + args.maximum + " élément(s)";
      }
    }
  })
})
