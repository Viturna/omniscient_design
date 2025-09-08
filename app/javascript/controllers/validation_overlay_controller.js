// app/javascript/controllers/validation_overlay_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["validation", "overlay", "overlayBottom"]

  connect() {
    this.hideValidationHandler = this.hideValidation.bind(this)
    this.seenValidationHandler = this.seenValidation.bind(this)

    window.addEventListener('scroll', this.hideValidationHandler)
    window.addEventListener('scroll', this.seenValidationHandler)
  }

  disconnect() {
    window.removeEventListener('scroll', this.hideValidationHandler)
    window.removeEventListener('scroll', this.seenValidationHandler)
  }

  hideValidation() {
    if (this.hasValidationTarget && this.hasOverlayTarget) {
      this.validationTarget.style.display = 'none'
      this.overlayTarget.style.display = 'none'
      window.removeEventListener('scroll', this.hideValidationHandler)
    }
  }

  seenValidation() {
    if (this.hasOverlayBottomTarget) {
      this.overlayBottomTarget.style.display = 'block'
      window.removeEventListener('scroll', this.seenValidationHandler)
    }
  }
}
