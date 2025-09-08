// app/javascript/controllers/back_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }
  static values = { fallbackUrl: String }

  handleClick(event) {
    event.preventDefault()

    if (window.history.length > 1) {
      window.history.back()
      return
    }

    const url = this.fallbackUrlValue || "/"
    window.location.assign(url)
  }
}
