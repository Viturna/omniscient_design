import * as jquery from "jquery"

// jQuery s'attache souvent à window automatiquement, mais on force le lien
window.jQuery = jquery.default || jquery
window.$ = window.jQuery