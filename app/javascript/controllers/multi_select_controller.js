// app/javascript/controllers/multi_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { prefix: String }

  connect() {
    this.selects = Array.from(document.querySelectorAll(`select[id^='${this.prefixValue}_']`))
    this.selects.forEach(select => {
      select.addEventListener("change", () => this.updateOptions())
    })
    this.updateOptions()
  }

  updateOptions() {
    const selectedValues = this.selects
      .map(select => select.value)
      .filter(value => value !== "")

    this.selects.forEach(select => {
      Array.from(select.options).forEach(option => {
        option.disabled = selectedValues.includes(option.value) && option.value !== select.value
      })
    })
  }
}
