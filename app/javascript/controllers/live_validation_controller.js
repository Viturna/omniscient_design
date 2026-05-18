import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "message"]
  static values = {
    availableText: String,
    takenText: String
  }

  async checkEmail() {
    const email = this.inputTarget.value
    if (!email || email.length < 5 || !email.includes('@')) {
      this.messageTarget.textContent = ""
      return
    }

    try {
      const response = await fetch(`/users/check_email?email=${encodeURIComponent(email)}`)
      const data = await response.json()
      
      if (data.available) {
        this.messageTarget.textContent = this.availableTextValue
        this.messageTarget.style.color = "#34A853"
      } else {
        this.messageTarget.textContent = this.takenTextValue
        this.messageTarget.style.color = "#E61818"
      }
    } catch (err) {
      console.error(err)
    }
  }

  async checkPseudo() {
    const pseudo = this.inputTarget.value
    if (!pseudo || pseudo.length < 2) {
      this.messageTarget.textContent = ""
      return
    }

    try {
      const response = await fetch(`/users/check_pseudo?pseudo=${encodeURIComponent(pseudo)}`)
      const data = await response.json()
      
      if (data.available) {
        this.messageTarget.textContent = this.availableTextValue
        this.messageTarget.style.color = "#34A853"
      } else {
        this.messageTarget.textContent = this.takenTextValue
        this.messageTarget.style.color = "#E61818"
      }
    } catch (err) {
      console.error(err)
    }
  }
}
