import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
    static targets = ["wrapper"]

    connect() {
        this.isDown = false
        this.startX = 0
        this.scrollLeft = 0
        
        // Drag events
        this.element.addEventListener("mousedown", this.onMouseDown.bind(this))
        this.element.addEventListener("mouseleave", this.onMouseLeave.bind(this))
        this.element.addEventListener("mouseup", this.onMouseUp.bind(this))
        this.element.addEventListener("mousemove", this.onMouseMove.bind(this))
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
