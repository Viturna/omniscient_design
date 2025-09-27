import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal", "button", "close", "x", "messages", "email",
    "whatsapp", "facebook", "copy", "link"
  ]

  connect() {
    if (!this.hasModalTarget) console.warn("No modal target found!")
    this.urlToShare = window.location.href
    this.textToShare = "Découvrez cette œuvre incroyable !"
    if (this.hasLinkTarget) this.linkTarget.value = this.urlToShare
  }

  open(event) {
    event.preventDefault()
    if (!this.hasModalTarget) return console.error("Modal target missing")
    this.modalTarget.style.display = "flex"
  }

  close() {
    if (!this.hasModalTarget) return
    this.modalTarget.style.display = "none"
  }

  backdropClose(event) {
    if (!this.hasModalTarget) return
    if (event.target === this.modalTarget) this.close()
  }

  shareX() {
    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(this.textToShare)}&url=${encodeURIComponent(this.urlToShare)}`, "_blank")
  }

  shareMessages() {
    window.open(`sms:?body=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`, "_self")
  }

  shareEmail() {
    window.open(`mailto:?subject=${encodeURIComponent("Découvrez cette œuvre !")}&body=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`, "_self")
  }

  shareWhatsApp() {
    window.open(`https://wa.me/?text=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`, "_blank")
  }

  shareFacebook() {
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlToShare)}`, "_blank")
  }

  copyLink() {
    if (!this.hasLinkTarget && !this.hasModalTarget) return
    const textarea = document.createElement("textarea")
    textarea.value = this.urlToShare
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    document.body.removeChild(textarea)
    alert("Lien copié dans le presse-papiers")
  }
}
