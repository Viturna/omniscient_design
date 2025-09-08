import { Controller } from "@hotwired/stimulus"

// data-controller="save"
export default class extends Controller {
  static targets = ["popup"]

  connect() {
    // Au cas où tu veux debug
    // console.log("Save controller connecté")
  }

  open(event) {
    event.preventDefault()
    this.popupTarget.classList.add("show")
  }

  close(event) {
    event.preventDefault()
    this.popupTarget.classList.remove("show")
  }

  backdropClose(event) {
    if (event.target === this.popupTarget) {
      this.close(event)
    }
  }
}
