// app/javascript/controllers/show_password_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passwordField", "showIcon", "hideIcon"]
  
  toggle() {
    if (this.passwordFieldTarget.type === "password") {
      this.passwordFieldTarget.type = "text"
      this.showIconTarget.style.display = "none"
      this.hideIconTarget.style.display = "inline"
    } else {
      this.passwordFieldTarget.type = "password"
      this.showIconTarget.style.display = "inline"
      this.hideIconTarget.style.display = "none"
    }
  }
}
