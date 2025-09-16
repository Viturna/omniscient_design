import { Controller } from "@hotwired/stimulus"
import "jquery"
import "select2"

window.$ = window.jQuery = window.$ || window.jQuery

export default class extends Controller {
  static targets = ["progressBar", "progressPercent"]

  connect() {
    this.updateProgress = this.updateProgress.bind(this)

    // Inputs natifs
    this.inputs = this.element.querySelectorAll("input:not([type=hidden]), textarea, select, [name^='oeuvre[source]']")

    this.inputs.forEach(input => {
      input.addEventListener("input", this.updateProgress)
    })

    this.select2Elements = $(this.element).find(".designer-select, .notions-select");
    this.select2Elements.on("change", this.updateProgress);

    this.select2Elements.on("change", this.updateProgress)

    // Init au chargement
    this.updateProgress()


  }

  disconnect() {
    this.inputs.forEach(input => {
      input.removeEventListener("input", this.updateProgress)
    })

    if (this.select2Elements) {
      this.select2Elements.off("change", this.updateProgress)
    }

  }

  updateProgress() {
    let filledInputs = 0
    let totalInputs = this.inputs.length

    // Inputs classiques
    this.inputs.forEach(input => {
      if (input.type === "checkbox" || input.type === "radio") {
        if (input.checked) filledInputs++
      } else if (input.value.trim() !== "") {
        filledInputs++
      }
    })

    // Inputs select2
    if (this.select2Elements) {
      totalInputs += this.select2Elements.length
      this.select2Elements.each(function () {
        if ($(this).val() && $(this).val().length > 0) {
          filledInputs++
        }
      })
    }

    // Progression
    const progressPercent = totalInputs > 0 ? Math.round((filledInputs / totalInputs) * 100) : 0

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${progressPercent}%`
    }

    if (this.hasProgressPercentTarget) {
      this.progressPercentTarget.textContent = `${progressPercent}%`
    }
  }
}
