import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "token"]

  connect() {
    // Liste des pages où reCAPTCHA doit être actif
    const allowedPages = [
      { controller: "designers", action: "new" },
      { controller: "registrations", action: "new" },
      { controller: "sessions", action: "new" }
    ]

    const currentController = document.body.dataset.controllerName
    const currentAction = document.body.dataset.actionName

    const isAllowed = allowedPages.some(page => page.controller === currentController && page.action === currentAction)
    if (!isAllowed) return  // Ne rien faire sur les autres pages

    this.siteKey = document.querySelector('meta[name="recaptcha-site-key"]').getAttribute('content')
    if (!this.formTarget) return

    this.formTarget.addEventListener("submit", (event) => this.handleSubmit(event))
    console.log("Recaptcha controller actif sur cette page, siteKey :", this.siteKey)

    if (typeof grecaptcha !== "undefined") {
      console.log("grecaptcha est chargé ✅")
    } else {
      console.warn("grecaptcha n'est pas encore chargé ⏳")
    }
  }

  handleSubmit(event) {
    event.preventDefault()
    if (typeof grecaptcha === "undefined") {
      console.error("reCAPTCHA n'est pas chargé")
      return
    }

    grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
      this.tokenTarget.value = token
      this.formTarget.submit()
    })
  }
}
