import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "button", "input"]

  connect() {
    const textarea = this.containerTarget.querySelector('textarea')
    
    if (textarea && textarea.value.trim() !== "") {
      this.showField()
    } else {
      this.hideField()
    }
  }

  reveal(event) {
    if(event) event.preventDefault()
    this.showField()
  }

  showField() {
    this.containerTarget.style.display = "block"
    this.buttonTarget.style.display = "none"
  }

  hideField() {
    this.containerTarget.style.display = "none"
    this.buttonTarget.style.display = "block"
  }
}