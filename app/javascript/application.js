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


document.addEventListener("turbo:load", () => {
    console.log("✅ Turbo load : scripts relancés")

    // Ré-init select2
    if ($(".select2").length) {
        $(".select2").select2()
    }

})