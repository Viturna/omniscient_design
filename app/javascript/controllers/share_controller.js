import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "link", "copyBtn"]

  connect() {
    // Log pour vérifier que le contrôleur est bien chargé
    console.log("Share controller connecté !")

    if (this.hasModalTarget) {
      console.log("Modal target trouvée !")
    } else {
      console.error("ERREUR : Modal target introuvable. Vérifiez votre HTML.")
    }

    // Pré-remplir l'input si présent
    this.urlToShare = window.location.href
    this.textToShare = "Découvrez cette référence incroyable !"

    if (this.hasLinkTarget) {
      this.linkTarget.value = this.urlToShare
    }
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation() // Empêche le clic de remonter

    if (!this.hasModalTarget) return

    this.modalTarget.style.display = "flex"

    // Bloquer le scroll du body (optionnel mais conseillé)
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event) event.preventDefault()

    if (!this.hasModalTarget) return

    this.modalTarget.style.display = "none"
    document.body.style.overflow = "" // Réactiver le scroll
  }

  backdropClose(event) {
    // Ferme uniquement si on clique sur le fond gris (l'overlay), pas le contenu
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  // --- ACTIONS DE PARTAGE ---

  shareX() {
    this.openWindow(`https://twitter.com/intent/tweet?text=${encodeURIComponent(this.textToShare)}&url=${encodeURIComponent(this.urlToShare)}`)
  }

  shareMessages() {
    window.location.href = `sms:?body=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`
  }

  shareEmail() {
    window.location.href = `mailto:?subject=${encodeURIComponent("Découvrez cette référence !")}&body=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`
  }

  shareWhatsApp() {
    this.openWindow(`https://wa.me/?text=${encodeURIComponent(this.textToShare + " " + this.urlToShare)}`)
  }

  shareFacebook() {
    this.openWindow(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlToShare)}`)
  }

  // Helper pour ouvrir proprement
  openWindow(url) {
    window.open(url, '_blank', 'width=600,height=400')
  }

  // --- COPIER LE LIEN (MODERNE) ---
  copyLink(event) {
    event.preventDefault()

    navigator.clipboard.writeText(this.urlToShare).then(() => {
      // Feedback visuel sur le bouton
      if (this.hasCopyBtnTarget) {
        const originalText = this.copyBtnTarget.innerText
        this.copyBtnTarget.innerText = "Copié !"
        this.copyBtnTarget.disabled = true

        setTimeout(() => {
          this.copyBtnTarget.innerText = originalText
          this.copyBtnTarget.disabled = false
        }, 2000)
      } else {
        alert("Lien copié !")
      }
    }).catch(err => {
      console.error('Erreur copie :', err)
    })
  }
}