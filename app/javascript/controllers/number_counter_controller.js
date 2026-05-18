import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]
  static values = {
    end: Number,
    duration: { type: Number, default: 2000 }
  }

  connect() {
    this.hasAnimated = false
    // Attendre que l'élément soit visible à l'écran
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.hasAnimated) {
          this.animate()
          this.hasAnimated = true
          this.observer.disconnect()
        }
      })
    }, { threshold: 0.1 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  animate() {
    let startTimestamp = null
    const end = this.endValue
    const duration = this.durationValue

    const step = (timestamp) => {
      if (!startTimestamp) startTimestamp = timestamp
      const progress = Math.min((timestamp - startTimestamp) / duration, 1)
      
      // Fonction d'assouplissement : easeOutExpo
      const easeProgress = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress)
      const current = Math.floor(easeProgress * end)
      
      this.valueTarget.textContent = "+" + current

      if (progress < 1) {
        window.requestAnimationFrame(step)
      } else {
        this.valueTarget.textContent = "+" + end
      }
    }

    window.requestAnimationFrame(step)
  }
}
