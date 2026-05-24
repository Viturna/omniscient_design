import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    target: String
  }

  connect() {
    this.targetDate = new Date(this.targetValue).getTime()
    this.update()
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  update() {
    const now = new Date().getTime()
    const distance = this.targetDate - now

    if (distance < 0) {
      this.element.textContent = "En cours..."
      clearInterval(this.timer)
      return
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24))
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((distance % (1000 * 60)) / 1000)

    let parts = []
    if (days > 0) {
      parts.push(`${days}j`)
      parts.push(`${hours}h`)
    } else {
      parts.push(`${hours.toString().padStart(2, '0')}h`)
      parts.push(`${minutes.toString().padStart(2, '0')}m`)
      parts.push(`${seconds.toString().padStart(2, '0')}s`)
    }

    this.element.textContent = parts.join(" ")
  }
}
