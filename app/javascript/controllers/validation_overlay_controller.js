// app/javascript/controllers/validation_overlay_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["validation", "overlay", "overlayBottom"]

  connect() {
    // Explicitly show the overlay elements
    if (this.hasValidationTarget) this.validationTarget.style.display = "flex"
    if (this.hasOverlayTarget) this.overlayTarget.style.display = "block"
    if (this.hasOverlayBottomTarget) this.overlayBottomTarget.style.display = "none"

    // Reset scroll to top
    window.scrollTo(0, 0)

    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll)

    // Ignore scroll events for the first 1000ms to avoid Turbo scroll restoration hiding the overlay
    this.isActive = false
    setTimeout(() => {
      this.isActive = true
    }, 1000)
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    if (!this.isActive) return;

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
