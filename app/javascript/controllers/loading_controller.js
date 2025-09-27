// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content"]

  connect() {
    // Initialisation à chaque navigation Turbo (y compris le premier chargement)
    document.addEventListener("turbo:load", () => this.init())

    // Avant qu'une nouvelle page soit rendue, on affiche le loader
    document.addEventListener("turbo:before-render", () => this.showLoading())
  }

  init() {
    // On affiche le contenu quand la page est chargée
    this.showContent()
  }

  showLoading() {
    if (this.hasLoadingTarget) this.loadingTarget.style.display = "flex"
    if (this.hasContentTarget) this.contentTarget.style.display = "none"
  }

  showContent() {
    if (this.hasLoadingTarget) this.loadingTarget.style.display = "none"
    if (this.hasContentTarget) this.contentTarget.style.display = "block"
  }
}
