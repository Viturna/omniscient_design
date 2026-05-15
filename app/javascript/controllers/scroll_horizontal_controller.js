import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"


export default class extends Controller {
    static targets = ["wrapper"]

    connect() {
        this.isDown = false
        this.startX = 0
        this.scrollLeft = 0

        this.element.addEventListener("wheel", this.onWheel.bind(this), { passive: false })
        
        // Drag events
        this.element.addEventListener("mousedown", this.onMouseDown.bind(this))
        this.element.addEventListener("mouseleave", this.onMouseLeave.bind(this))
        this.element.addEventListener("mouseup", this.onMouseUp.bind(this))
        this.element.addEventListener("mousemove", this.onMouseMove.bind(this))
    }

    onWheel(e) {
        const container = this.element
        // On bloque le scroll vertical de la page dès qu'on est sur le container
        // si on n'est pas au bout du défilement
        const isAtEnd = Math.ceil(container.scrollLeft + container.clientWidth) >= container.scrollWidth
        const isAtStart = container.scrollLeft <= 0

        if ((e.deltaY > 0 && !isAtEnd) || (e.deltaY < 0 && !isAtStart)) {
            e.preventDefault()
            container.scrollLeft += e.deltaY * 1.5 // Sensibilité un peu augmentée
        }
    }

    onMouseDown(e) {
        this.isDown = true
        this.element.classList.add("active")
        this.startX = e.pageX - this.element.offsetLeft
        this.scrollLeft = this.element.scrollLeft
    }

    onMouseLeave() {
        this.isDown = false
        this.element.classList.remove("active")
    }

    onMouseUp() {
        this.isDown = false
        this.element.classList.remove("active")
    }

    onMouseMove(e) {
        if (!this.isDown) return
        e.preventDefault()
        const x = e.pageX - this.element.offsetLeft
        const walk = (x - this.startX) * 2 // Sensibilité du drag
        this.element.scrollLeft = this.scrollLeft - walk
    }
}
