import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "token"]

  connect() {
    document.addEventListener("turbo:load", () => this.initRecaptcha())
  }

  initRecaptcha() {
    const allowedPages = [
      { controller: "designers", action: "new" },
      { controller: "registrations", action: "new" },
      { controller: "sessions", action: "new" }
    ]

    const currentController = document.body.dataset.controllerName
    const currentAction = document.body.dataset.actionName

    const isAllowed = allowedPages.some(
      page => page.controller === currentController && page.action === currentAction
    )
    if (!isAllowed) return

    const metaTag = document.querySelector('meta[name="recaptcha-site-key"]')
    if (!metaTag) return
    this.siteKey = metaTag.getAttribute('content')

    if (!this.hasFormTarget) return

    // Supprime un éventuel listener précédent pour éviter les doublons
    this.formTarget.removeEventListener("submit", this.handleSubmit)
    this.formTarget.addEventListener("submit", (event) => this.handleSubmit(event))
  }

  handleSubmit(event) {
    event.preventDefault()
    if (typeof grecaptcha === "undefined") return

    grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
        this.tokenTarget.value = token
        this.formTarget.submit()
      })
    })
  }
}
