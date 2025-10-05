import { Controller } from "@hotwired/stimulus"
import "jquery"
import "select2"

window.$ = window.jQuery = window.$ || window.jQuery

export default class extends Controller {
  static targets = ["progressBar", "progressPercent"]

  connect() {
    this.updateProgress = this.updateProgress.bind(this)

    // boutons next / prev
    const stepButtons = this.element.querySelectorAll(".next-step, .prev-step")
    stepButtons.forEach(btn => {
      btn.addEventListener("click", (e) => {
        this.changeStep(e.target)
      })
    })

    // select2
    this.select2Elements = $(this.element).find(".designer-select, .notions-select")
    this.select2Elements.on("change", this.updateProgress)

    // initial update
    this.updateProgress()
  }

  disconnect() {
    const stepButtons = this.element.querySelectorAll(".next-step, .prev-step")
    stepButtons.forEach(btn => btn.removeEventListener("click", this.changeStep))

    if (this.select2Elements) {
      this.select2Elements.off("change", this.updateProgress)
    }
  }

  changeStep(button) {
    const currentStep = button.closest(".form-step")
    const currentStepNum = parseInt(currentStep.dataset.step)
    const nextStepNum = button.classList.contains("next-step") ? currentStepNum + 1 : currentStepNum - 1

    const steps = this.element.querySelectorAll(".form-step")
    steps.forEach(step => step.style.display = "none")

    const nextStep = this.element.querySelector(`.form-step[data-step='${nextStepNum}']`)
    if (nextStep) nextStep.style.display = "block"

    this.updateProgress(nextStepNum)
  }

  updateProgress(currentStepIndex = null) {
    const steps = this.element.querySelectorAll(".form-step")
    const totalSteps = steps.length

    if (currentStepIndex === null) {
      // fallback si pas passé en argument
      steps.forEach((step, idx) => {
        if (step.style.display !== "none") currentStepIndex = idx + 1
      })
    }

    const progressPercent = Math.round((currentStepIndex / totalSteps) * 100)

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${progressPercent}%`
    }

    if (this.hasProgressPercentTarget) {
      this.progressPercentTarget.textContent = `${progressPercent}%`
    }
  }
}
