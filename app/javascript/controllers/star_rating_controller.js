import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    document.addEventListener("turbo:load", () => this.init())
    const value = this.inputTarget.value || 0
    this.updateStars(value)
  }

  rate(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.updateStars(value)
  }

  updateStars(value) {
    this.starTargets.forEach(star => {
      if (parseInt(star.dataset.value) <= parseInt(value)) {
        star.querySelector("svg path").setAttribute("fill", "#f5c518")
      } else {
        star.querySelector("svg path").setAttribute("fill", "#ddd")
      }
    })
  }
}
