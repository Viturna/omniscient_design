// app/javascript/controllers/slider_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["slide", "dot", "background"]
    static values = {
        index: { type: Number, default: 0 },
        updateBackground: { type: Boolean, default: false }
    }

    connect() {
        this.showCurrentSlide()
    }

    // --- Fonctions next, prev, switchSlide (INCHANGÉES) ---
    next(event) {
        if (event) {
            event.preventDefault()
            event.stopPropagation()
        }
        if (this.indexValue < this.slideTargets.length - 1) {
            this.indexValue++
        } else {
            this.indexValue = 0
        }
    }

    prev(event) {
        if (event) {
            event.preventDefault()
            event.stopPropagation()
        }
        if (this.indexValue > 0) {
            this.indexValue--
        } else {
            this.indexValue = this.slideTargets.length - 1
        }
    }

    switchSlide(event) {
        if (event) {
            event.preventDefault()
            event.stopPropagation()
        }
        this.indexValue = parseInt(event.currentTarget.dataset.sliderIndexValue)
    }
    // --- Fin des fonctions inchangées ---


    indexValueChanged() {
        this.showCurrentSlide()
    }

    // La fonction principale qui met à jour l'affichage
    showCurrentSlide() {
        // 1. Met à jour les slides
        if (this.hasSlideTarget) {
            this.slideTargets.forEach((slide, i) => {
                slide.classList.toggle("active", i === this.indexValue)
            })
        }

        // 2. Met à jour les dots
        if (this.hasDotTarget) {
            this.dotTargets.forEach((dot, i) => {
                dot.classList.toggle("active", i === this.indexValue)
            })
        }

        // 3. Logique conditionnelle pour le fond (MODIFIÉE)
        if (this.updateBackgroundValue) {
            if (this.slideTargets.length === 0) return;

            const currentSlide = this.slideTargets[this.indexValue]

            if (currentSlide && currentSlide.tagName === "IMG") {
                const newImageUrl = currentSlide.src
                if (newImageUrl) {

                    // *** LA MODIFICATION CLÉ ***
                    // On cherche l'élément cible :
                    // 1. 'this.backgroundTarget' s'il existe (pour la carte)
                    // 2. 'this.element' sinon (pour la page oeuvre)
                    const targetElement = this.hasBackgroundTarget ? this.backgroundTarget : this.element;

                    // On applique le style à la bonne cible
                    targetElement.style.backgroundImage = `url('${newImageUrl}')`;
                }
            }
        }
    }
}