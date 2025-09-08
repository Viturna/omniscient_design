// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content"]

  connect() {

    // Au premier rendu
    this.showLoading()

    // Navigation Turbo avant remplacement
    document.addEventListener("turbo:before-render", () => {
      this.showLoading()
    })

    // Navigation Turbo après rendu
    document.addEventListener("turbo:load", () => {
      this.showContent()
    })

  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "flex"
    }
    if (this.hasContentTarget) {
      this.contentTarget.style.display = "none"
    }
  }

  showContent() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "none"
    }
    if (this.hasContentTarget) {
      this.contentTarget.style.display = "block"
    }
  }
}
