import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu", "toggle"]

    connect() {
        document.addEventListener("turbo:load", () => this.init())
        if (this.hasToggleTarget && this.hasMenuTarget) {
            this.toggleTarget.addEventListener("click", this.toggle)
            document.addEventListener("click", this.closeOnOutsideClick)
        }
    }

    disconnect() {
        if (this.hasToggleTarget && this.hasMenuTarget) {
            this.toggleTarget.removeEventListener("click", this.toggle)
            document.removeEventListener("click", this.closeOnOutsideClick)
        }
    }

    toggle = (event) => {
        event.stopPropagation()
        this.menuTarget.classList.toggle("active")
    }

    closeOnOutsideClick = (event) => {
        if (!this.element.contains(event.target)) {
            this.menuTarget.classList.remove("active")
        }
    }
}
