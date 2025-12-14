import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        oeuvreId: String,
        designerId: String,
        studioId: String
    }

    open(event) {
        event.preventDefault()
        event.stopPropagation()

        const modal = document.getElementById("saveModalOverlay")
        const frame = document.getElementById("save_modal_content")
        const content = modal.querySelector('.popup-content')

        if (!modal || !frame) return

        modal.setAttribute("data-lenis-prevent", "true")
        if (content) content.setAttribute("data-lenis-prevent", "true")

        if (this.hasOeuvreIdValue) {
            frame.src = `/oeuvres/${this.oeuvreIdValue}/save_modal`
        } else if (this.hasDesignerIdValue) {
            frame.src = `/designers/${this.designerIdValue}/save_modal`
        } else if (this.hasStudioIdValue) {
            frame.src = `/studios/${this.studioIdValue}/save_modal`
        }

        modal.style.display = "flex"

        modal.onclick = (e) => {
            if (e.target === modal) modal.style.display = "none"
        }
    }
}