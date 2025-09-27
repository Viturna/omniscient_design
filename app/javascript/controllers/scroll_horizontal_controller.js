import { Controller } from "@hotwired/stimulus"
import gsap from "gsap"

export default class extends Controller {
    static targets = ["wrapper"]

    connect() {
        document.addEventListener("turbo:load", () => this.init())
        this.wrapper = this.wrapperTarget
        this.wrapper.style.overflow = "hidden" // masque la scrollbar
        this.wrapper.addEventListener("wheel", this.onWheel.bind(this))
    }

    onWheel(e) {
        e.preventDefault() // empêche le scroll vertical par défaut

        const scrollAmount = e.deltaY || e.deltaX // récupère le mouvement de la molette
        const currentX = this.wrapper.scrollLeft

        // GSAP pour un scroll fluide
        gsap.to(this.wrapper, {
            scrollLeft: currentX + scrollAmount,
            duration: 0.5,
            ease: "power2.out"
        })
    }
}
