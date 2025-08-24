import "@hotwired/turbo-rails"
import "controllers"

import jQuery from "jquery"

import $ from "jquery"
window.$ = jQuery
window.jQuery = jQuery
import "select2"
function initSelect2() {
  console.log("Initialisation de Select2")
  const selects = document.querySelectorAll('.select2')
  selects.forEach(select => {
    if (!$(select).hasClass("select2-hidden-accessible")) {
      $(select).select2()
    }
  })
}

document.addEventListener("turbo:load", () => {
  initSelect2()
})

function toggleLoading(show) {
  const loading = document.querySelector('#loading')
  const content = document.querySelector('#content')
  if (!loading || !content) return

  loading.style.display = show ? 'block' : 'none'
  content.style.display = show ? 'none' : 'block'
}

// Quand Turbo va remplacer le body → on réaffiche le loader
document.addEventListener('turbo:before-render', () => toggleLoading(true))

// Quand la nouvelle page est prête → on cache le loader et on montre le contenu
document.addEventListener('turbo:load', () => toggleLoading(false))
