import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  validate(event) {
    const input = event.currentTarget
    const errorContainer = this.errorTargets.find(el => el.dataset.for === input.id)
    const year = parseInt(input.value)
    const currentYear = new Date().getFullYear()

    if (input.value && (!Number.isInteger(year) || year < 0 || year > currentYear)) {
      if (errorContainer) {
        errorContainer.textContent = `Année invalide (entre 0 et ${currentYear})`
      }
    } else {
      if (errorContainer) {
        errorContainer.textContent = ""
      }
    }
  }
}