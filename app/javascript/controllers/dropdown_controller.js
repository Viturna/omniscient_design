import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu", "toggle"]

    connect() {
        if (this.hasToggleTarget && this.hasMenuTarget) {
            this.toggleTarget.addEventListener("click", this.toggle)
            document.addEventListener("click", this.closeOnOutsideClick)
        }

        const applyBtn = document.getElementById("applyDateFilter")
        if (applyBtn) {
            applyBtn.addEventListener("click", this.applyDateFilter)
        }
    }

    disconnect() {
        if (this.hasToggleTarget && this.hasMenuTarget) {
            this.toggleTarget.removeEventListener("click", this.toggle)
            document.removeEventListener("click", this.closeOnOutsideClick)
        }

        const applyBtn = document.getElementById("applyDateFilter")
        if (applyBtn) {
            applyBtn.removeEventListener("click", this.applyDateFilter)
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

    applyDateFilter = () => {
        const start = document.getElementById("startDate").value
        const end = document.getElementById("endDate").value

        const url = new URL(window.location.href)

        if (start) url.searchParams.set("start_year", start)
        else url.searchParams.delete("start_year")

        if (end) url.searchParams.set("end_year", end)
        else url.searchParams.delete("end_year")

        window.location.href = url.toString()
    }
}
