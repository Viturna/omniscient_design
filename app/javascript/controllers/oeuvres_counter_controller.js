// app/javascript/controllers/oeuvres_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hiddenOeuvres"]

    toggle(event) {
        let hiddenOeuvres = this.hiddenOeuvresTarget
        if (hiddenOeuvres.style.display === "none" || hiddenOeuvres.style.display === "") {
            hiddenOeuvres.style.display = "flex"
        } else {
            hiddenOeuvres.style.display = "none"
        }
    }
}
