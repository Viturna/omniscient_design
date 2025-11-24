import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal"]

    connect() {
        // On s'assure que la popup est cachée au chargement
        this.close()
    }

    open(event) {
        if (event) event.preventDefault()
        this.modalTarget.style.display = "flex"
    }

    close(event) {
        if (event) event.preventDefault()
        this.modalTarget.style.display = "none"
    }

    // Ferme la popup si on clique sur le fond gris (l'élément modal lui-même)
    backgroundClick(event) {
        if (event.target === this.modalTarget) {
            this.close()
        }
    }
}