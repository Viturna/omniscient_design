// app/javascript/controllers/slider_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["slide", "dot", "background"]
    static values = {
        index: { type: Number, default: 0 },
        updateBackground: { type: Boolean, default: false }
    }

    // 🌟 Ajout de la méthode de recalcul pour les éléments cachés
    recalculate() {
        this.showCurrentSlide();
    }

    connect() {
        this.showCurrentSlide()
    }

    // Gère l'événement "click->slider#next"
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

    // Gère l'événement "click->slider#prev"
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

    // Gère l'événement "click->slider#switchSlide"
    switchSlide(event) {
        if (event) {
            event.preventDefault()
            event.stopPropagation()
        }
        this.indexValue = parseInt(event.currentTarget.dataset.sliderIndexValue)
    }


    indexValueChanged() {
        this.showCurrentSlide()

        // Déclenche l'événement custom pour la modale afin de mettre à jour les crédits
        this.element.dispatchEvent(new CustomEvent('slide:changed', {
            bubbles: true,
            detail: { index: this.indexValue }
        }))
    }

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

        // 3. Logique conditionnelle pour le fond
        if (this.updateBackgroundValue) {
            if (this.slideTargets.length === 0) return;

            const currentSlide = this.slideTargets[this.indexValue]

            if (currentSlide && currentSlide.tagName === "IMG") {
                const newImageUrl = currentSlide.src
                if (newImageUrl) {
                    const targetElement = this.hasBackgroundTarget ? this.backgroundTarget : this.element;
                    targetElement.style.backgroundImage = `url('${newImageUrl}')`;
                }
            }
        }
    }
}