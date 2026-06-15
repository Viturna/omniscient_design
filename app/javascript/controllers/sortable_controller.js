// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static targets = ["item", "positionInput", "positionLabel"]

    connect() {
        this.sortable = Sortable.create(this.element, {
            animation: 150,
            handle: ".image-drag-handle",
            onEnd: this.updatePositions.bind(this)
        });

        this.updatePositions();
    }

    disconnect() {
        this.sortable.destroy()
    }

    // Met à jour la valeur de tous les champs de position
    updatePositions() {
        this.itemTargets.forEach((item, index) => {
            const pos = index + 1;
            const input = item.querySelector('[data-sortable-target="positionInput"]')
            if (input) {
                input.value = pos;
            }
            const label = item.querySelector('[data-sortable-target="positionLabel"]')
            if (label) {
                label.innerText = pos;
            }
        });
    }
}