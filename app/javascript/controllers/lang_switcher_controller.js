// app/javascript/controllers/lang_switcher_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["dropdown", "current"]

    connect() {
        // Initial state
        this.dropdownTarget.classList.remove('open');

        // Event listener pour fermer le dropdown si clic en dehors
        this.outsideClickListener = (event) => {
            if (!this.element.contains(event.target)) {
                this.closeDropdown();
            }
        };
        document.addEventListener('click', this.outsideClickListener);
    }

    disconnect() {
        document.removeEventListener('click', this.outsideClickListener);
    }

    toggle() {
        this.element.classList.toggle('open');
    }

    select(event) {
        const option = event.currentTarget;
        this.currentTarget.textContent = option.dataset.lang;
        this.closeDropdown();
        // La redirection se fera naturellement via le href du <a>
    }

    closeDropdown() {
        this.element.classList.remove('open');
    }
}
