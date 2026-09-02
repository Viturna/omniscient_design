import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "banner", "select"]

  connect() {
    const isDismissed = sessionStorage.getItem("back-to-school-modal-dismissed")

    if (isDismissed === "true") {
      this.showBannerOnly()
    } else {
      this.showModal()
    }
  }

  showModal() {
    if (this.hasModalTarget) {
      this.modalTarget.style.display = "flex"
      this.modalTarget.setAttribute("data-lenis-prevent", "true")
    }
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = "none"
    }
  }

  closeModal(event) {
    if (event) event.preventDefault()
    if (this.hasModalTarget) {
      this.modalTarget.style.display = "none"
    }
    // Quand on ferme la modale sans valider, on active le mode bannière pour la session
    sessionStorage.setItem("back-to-school-modal-dismissed", "true")
    this.showBannerOnly()
  }

  showBannerOnly() {
    if (this.hasModalTarget) {
      this.modalTarget.style.display = "none"
    }
    if (this.hasBannerTarget) {
      this.bannerTarget.style.display = "flex"
    }
  }

  openModalFromBanner(event) {
    if (event) event.preventDefault()
    this.showModal()
  }

  backgroundClick(event) {
    if (event.target === this.modalTarget) {
      this.closeModal(event)
    }
  }
}
