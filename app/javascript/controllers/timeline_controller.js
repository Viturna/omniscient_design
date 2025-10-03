import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {

        // Mise à jour initiale
        this.updateLine()

        // Observer les changements de taille du conteneur
        this.resizeObserver = new ResizeObserver(() => this.updateLine())
        this.resizeObserver.observe(this.element)

        // Observer les changements de contenu (ex: oeuvres ajoutées dynamiquement)
        this.mutationObserver = new MutationObserver(() => this.updateLine())
        this.mutationObserver.observe(this.element, { childList: true, subtree: true })
    }

    disconnect() {
        if (this.resizeObserver) this.resizeObserver.disconnect()
        if (this.mutationObserver) this.mutationObserver.disconnect()
    }

    updateLine() {
        // On utilise requestAnimationFrame pour s'assurer que le rendu est complet
        requestAnimationFrame(() => {
            const scrollWidth = this.element.scrollWidth
            this.element.style.setProperty("--line-width", `${scrollWidth}px`)
        })
    }
}
