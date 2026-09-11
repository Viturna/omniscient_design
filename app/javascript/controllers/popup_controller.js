import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "reasonInput", "reasonChip"]

    connect() {
        if (this.hasModalTarget) {
            this.modalTarget.setAttribute("data-lenis-prevent", "true")
            this.close()
        }
    }

    open(event) {
        if (event) event.preventDefault()
        if (this.hasModalTarget) {
            this.modalTarget.style.display = "flex"
        }
    }

    close(event) {
        if (event) event.preventDefault()
        if (this.hasModalTarget) {
            this.modalTarget.style.display = "none"
        }
    }

    backgroundClick(event) {
        if (event.target === this.modalTarget) {
            this.close()
        }
    }

    selectReason(event) {
        event.preventDefault()
        const button = event.currentTarget
        const reason = button.dataset.reason

        if (this.hasReasonChipTarget) {
            this.reasonChipTargets.forEach(chip => chip.classList.remove("active"))
        }

        button.classList.add("active")

        if (this.hasReasonInputTarget) {
            this.reasonInputTarget.value = reason
            this.reasonInputTarget.focus()
        }
    }
}