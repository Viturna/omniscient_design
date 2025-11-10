import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["token"]

  connect() {
    this.initRecaptcha()
  }

  initRecaptcha() {
    const metaTag = document.querySelector('meta[name="recaptcha-site-key"]')
    if (!metaTag) {
      console.error("Meta tag recaptcha-site-key not found")
      return
    }
    this.siteKey = metaTag.getAttribute('content')

    // On s'assure de ne pas avoir de doublons d'écouteurs
    if (this.submitHandler) {
      this.element.removeEventListener("submit", this.submitHandler)
    }
    this.submitHandler = this.handleSubmit.bind(this)
    this.element.addEventListener("submit", this.submitHandler)
  }

  disconnect() {
    if (this.submitHandler) {
      this.element.removeEventListener("submit", this.submitHandler)
    }
  }

  handleSubmit(event) {
    // Si le token est déjà rempli, on laisse le formulaire se soumettre normalement
    if (this.tokenTarget.value) return

    // Sinon, on empêche la soumission et on lance reCAPTCHA
    event.preventDefault()
    event.stopImmediatePropagation() // Important pour bloquer d'autres scripts potentiels

    if (typeof grecaptcha === "undefined") {
      console.error("reCAPTCHA n'est pas chargé.")
      // Fallback : on soumet sans token si reCAPTCHA ne charge pas (risque de spam, mais ne bloque pas l'user)
      this.element.submit()
      return
    }

    grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
        this.tokenTarget.value = token
        // On relance la soumission maintenant que le token est là
        // Utiliser requestSubmit() si possible pour déclencher les validations natives, sinon submit()
        if (typeof this.element.requestSubmit === 'function') {
          this.element.requestSubmit()
        } else {
          this.element.submit()
        }
      }, (error) => {
        console.error("Erreur reCAPTCHA execution:", error)
        // En cas d'erreur, on essaie quand même de soumettre
        this.element.submit()
      })
    })
  }
}