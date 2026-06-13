import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "button"]

  connect() {
    const input = this.containerTarget.querySelector('input[type="hidden"], textarea')

    if (input && input.value.trim() !== "") {
      this.showField()
    } else {
      this.hideField()
    }
  }

  reveal(event) {
    if (event) event.preventDefault()
    this.showField()
  }

  showField() {
    this.containerTarget.style.display = "flex"
    this.containerTarget.style.visibility = ""
    this.containerTarget.style.height = ""
    this.containerTarget.style.overflow = ""
    this.containerTarget.style.position = ""
    this.buttonTarget.style.display = "none"
  }

  hideField() {
    // On utilise visibility:hidden + height:0 au lieu de display:none
    // pour que Trix puisse s'initialiser correctement en arrière-plan
    this.containerTarget.style.visibility = "hidden"
    this.containerTarget.style.height = "0"
    this.containerTarget.style.overflow = "hidden"
    this.containerTarget.style.position = "absolute"
    this.containerTarget.style.display = ""
    this.buttonTarget.style.display = "flex"
  }
}