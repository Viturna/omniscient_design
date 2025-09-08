// app/javascript/controllers/recaptcha_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "token"]

  connect() {
    this.siteKey = document.querySelector('meta[name="recaptcha-site-key"]').getAttribute('content')
    this.formTarget.addEventListener("submit", (event) => this.handleSubmit(event))
  }

  handleSubmit(event) {
    event.preventDefault() // Empêche l'envoi immédiat du formulaire

    if (typeof grecaptcha === "undefined") {
      console.error("reCAPTCHA n'est pas chargé")
      return
    }

    grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
      this.tokenTarget.value = token
      this.formTarget.submit() // Soumet le formulaire après obtention du token
    })
  }
}
