// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static targets = ["item", "positionInput"]

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
            const input = item.querySelector('[data-sortable-target="positionInput"]')
            if (input) {
                input.value = index + 1;
            }
        });
    }
}