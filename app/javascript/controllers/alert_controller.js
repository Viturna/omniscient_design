import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress", "close"]

  connect() {
    this.countdownDuration = 5000
    this.width = 0

    if (this.progressTarget) {
      this.interval = setInterval(() => this.updateProgress(), 100)
    }

    this.closeTargets.forEach(btn => {
      btn.addEventListener("click", () => this.closeAlert())
    })
  }

  updateProgress() {
    this.width += 100 / (this.countdownDuration / 100)
    this.progressTarget.style.width = this.width + "%"

    if (this.width >= 100) {
      clearInterval(this.interval)
      this.closeAlert()
    }
  }

  closeAlert() {
    this.element.style.opacity = "0"
    setTimeout(() => {
      this.element.style.display = "none"
    }, 600)
    clearInterval(this.interval)
  }
}
