// app/javascript/controllers/references_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hiddenReferences"]

    toggle(event) {
        let hiddenReferences = this.hiddenReferencesTarget
        if (hiddenReferences.style.display === "none" || hiddenReferences.style.display === "") {
            hiddenReferences.style.display = "flex"
        } else {
            hiddenReferences.style.display = "none"
        }
    }
}
