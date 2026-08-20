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
        
        this.handleOtherDropdownOpen = this.handleOtherDropdownOpen.bind(this)
        window.addEventListener("dropdown:open", this.handleOtherDropdownOpen)
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
        
        window.removeEventListener("dropdown:open", this.handleOtherDropdownOpen)
    }

    handleOtherDropdownOpen(event) {
        if (event.detail.currentDropdown !== this.element && this.hasMenuTarget) {
            if (this.menuTarget.classList.contains("active")) {
                this.menuTarget.classList.remove("active")
                document.body.classList.remove("dropdown-open")
            }
        }
    }

    toggle = (event) => {
        event.stopPropagation()
        
        if (!this.menuTarget.classList.contains("active")) {
            window.dispatchEvent(new CustomEvent("dropdown:open", { detail: { currentDropdown: this.element } }))
            this.menuTarget.classList.add("active")
            document.body.classList.add("dropdown-open")
        } else {
            this.menuTarget.classList.remove("active")
            document.body.classList.remove("dropdown-open")
        }
    }

    closeOnOutsideClick = (event) => {
        if (!this.element.contains(event.target) && this.hasMenuTarget) {
            if (this.menuTarget.classList.contains("active")) {
                this.menuTarget.classList.remove("active")
                document.body.classList.remove("dropdown-open")
            }
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
