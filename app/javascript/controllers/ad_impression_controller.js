import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.hasTracked = false

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        // Déclenché uniquement lorsque la carte est visible à au moins 50% dans le viewport
        if (entry.isIntersecting && !this.hasTracked) {
          this.trackImpression()
        }
      })
    }, {
      threshold: 0.5
    })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  trackImpression() {
    this.hasTracked = true
    if (this.observer) {
      this.observer.unobserve(this.element)
    }

    if (this.urlValue) {
      fetch(this.urlValue, {
        method: "GET",
        headers: { "X-Requested-With": "XMLHttpRequest" }
      }).catch(() => {})
    }
  }
}
