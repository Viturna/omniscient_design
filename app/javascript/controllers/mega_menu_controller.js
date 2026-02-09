// app/javascript/controllers/mega_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "label", "button"]

    connect() {
        this.updateLabel()
        this.clickOutsideHandler = (e) => {
            if (!this.element.contains(e.target)) {
                this.contentTarget.classList.remove('active')
                this.buttonTarget.classList.remove('active')
            }
        }
        document.addEventListener('click', this.clickOutsideHandler)
    }

    disconnect() {
        document.removeEventListener('click', this.clickOutsideHandler)
    }

    toggle(event) {
        event.preventDefault()
        this.contentTarget.classList.toggle('active')
        this.buttonTarget.classList.toggle('active')
    }

    // --- NOUVELLE FONCTION ---
    toggleAccordion(event) {
        const header = event.currentTarget
        const content = header.nextElementSibling // C'est la div .mega-menu-items juste après
        const icon = header.querySelector('.chevron-icon') // L'icône flèche

        // Basculer la classe 'open' sur le contenu
        content.classList.toggle('open')

        // Basculer la classe 'active' sur le header (pour le style)
        header.classList.toggle('active')

        // Rotation de la flèche
        if (content.classList.contains('open')) {
            icon.style.transform = 'rotate(180deg)'
        } else {
            icon.style.transform = 'rotate(0deg)'
        }
    }
    // -------------------------

    updateLabel() {
        const checkboxes = this.element.querySelectorAll('input[type="checkbox"]:checked')
        const count = checkboxes.length

        if (count > 0) {
            this.labelTarget.innerText = `${count} Notion(s)`
            this.buttonTarget.classList.add('has-selection')
        } else {
            this.labelTarget.innerText = "Notions"
            this.buttonTarget.classList.remove('has-selection')
        }
    }
}