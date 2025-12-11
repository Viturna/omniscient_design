import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal"]

    connect() {
        this.modalTarget.setAttribute("data-lenis-prevent", "true")

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

    backgroundClick(event) {
        if (event.target === this.modalTarget) {
            this.close()
        }
    }
}