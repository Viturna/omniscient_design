// app/javascript/controllers/validation_overlay_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["validation", "overlay", "overlayBottom"]

  connect() {
    document.addEventListener("turbo:load", () => this.init())
    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    // seuil de scroll
    if (window.scrollY > 60) {

      if (this.hasValidationTarget) {
        this.validationTarget.style.display = "none"
      }

      if (this.hasOverlayTarget) {
        this.overlayTarget.style.display = "none"
      }

      if (this.hasOverlayBottomTarget) {
        this.overlayBottomTarget.style.display = "block"
      }

      window.removeEventListener("scroll", this.onScroll)
    }
  }
}
