import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "token"]

  connect() {
    console.group("Stimulus Recaptcha Controller Connect")

    // Liste des pages où reCAPTCHA doit être actif
    const allowedPages = [
      { controller: "designers", action: "new" },
      { controller: "registrations", action: "new" },
      { controller: "sessions", action: "new" }
    ]

    const currentController = document.body.dataset.controllerName
    const currentAction = document.body.dataset.actionName
    console.log("Current controller:", currentController)
    console.log("Current action:", currentAction)

    const isAllowed = allowedPages.some(page => page.controller === currentController && page.action === currentAction)
    console.log("Page autorisée pour reCAPTCHA:", isAllowed)
    if (!isAllowed) {
      console.groupEnd()
      return  // Ne rien faire sur les autres pages
    }

    const metaTag = document.querySelector('meta[name="recaptcha-site-key"]')
    if (!metaTag) {
      console.error("Meta tag recaptcha-site-key introuvable !")
      console.groupEnd()
      return
    }

    this.siteKey = metaTag.getAttribute('content')
    console.log("Clé site reCAPTCHA:", this.siteKey)

    if (!this.formTarget) {
      console.warn("Form target introuvable")
      console.groupEnd()
      return
    }

    this.formTarget.addEventListener("submit", (event) => this.handleSubmit(event))
    console.log("Écouteur submit ajouté sur le formulaire :", this.formTarget)

    if (typeof grecaptcha !== "undefined") {
      console.log("grecaptcha est chargé ✅")
    } else {
      console.warn("grecaptcha n'est pas encore chargé ⏳")
    }

    console.groupEnd()
  }

  handleSubmit(event) {
    console.group("Recaptcha handleSubmit")
    event.preventDefault()
    console.log("Formulaire soumis, preventDefault appelé")

    if (typeof grecaptcha === "undefined") {
      console.error("reCAPTCHA n'est pas chargé")
      console.groupEnd()
      return
    }

    console.log("grecaptcha présent, exécution reCAPTCHA...")
    grecaptcha.ready(() => {
      console.log("grecaptcha.ready exécuté")
      grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
        console.log("Token reCAPTCHA reçu:", token)
        this.tokenTarget.value = token
        console.log("Token injecté dans input :", this.tokenTarget)
        this.formTarget.submit()
        console.log("Formulaire soumis avec token ✅")
      }).catch((err) => {
        console.error("Erreur lors de l'exécution de grecaptcha.execute:", err)
      })
    })

    console.groupEnd()
  }
}
