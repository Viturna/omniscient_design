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

// ------------------------
// FUNCTIONS
// ------------------------
function initSelect2() {
  console.log("Initialisation de Select2")
  const selects = document.querySelectorAll('.select2')
  selects.forEach(select => {
    if (!$(select).hasClass("select2-hidden-accessible")) {
      $(select).select2()
    }
  })
}

// ------------------------
// EVENT LISTENERS
// ------------------------
document.addEventListener("turbo:load", () => {
  initSelect2()
})
document.addEventListener('turbo:before-render', () => toggleLoading(true))
