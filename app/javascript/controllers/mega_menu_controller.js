import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "content",
        "label",
        "button",
        "themesView",
        "notionsView",
        "themeColumn",
        "selectedThemeTitle"
    ]

    connect() {
        this.updateLabel()
        this.clickOutsideHandler = (e) => {
            if (!this.element.contains(e.target)) {
                this.contentTarget.classList.remove('active')
                this.buttonTarget.classList.remove('active')
                // Optionnel : tu peux décommenter la ligne ci-dessous si tu veux que 
                // le menu revienne toujours aux thèmes quand on le ferme.
                // this.backToThemes()
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

    // --- NAVIGATION THEMES <-> NOTIONS ---

    selectTheme(event) {
        // Récupère le nom du thème cliqué
        const themeName = event.currentTarget.dataset.themeName;

        // 1. Cacher la vue des carrés (Thèmes)
        this.themesViewTarget.style.display = 'none';

        // 2. Mettre à jour le titre dans l'en-tête de retour
        this.selectedThemeTitleTarget.innerText = themeName;

        // 3. Afficher UNIQUEMENT les accordéons du thème sélectionné
        this.themeColumnTargets.forEach(column => {
            if (column.dataset.themeName === themeName) {
                column.style.display = 'block'; // Affiche la colonne correspondante
            } else {
                column.style.display = 'none';
            }
        });

        this.notionsViewTarget.style.display = 'block';
    }

    backToThemes() {
        this.notionsViewTarget.style.display = 'none';
        this.themesViewTarget.style.display = 'block';
    }

    // --- ACCORDÉONS ---

    toggleAccordion(event) {
        const header = event.currentTarget
        const content = header.nextElementSibling
        const icon = header.querySelector('.chevron-icon')

        content.classList.toggle('open')
        header.classList.toggle('active')

        if (content.classList.contains('open')) {
            icon.style.transform = 'rotate(180deg)'
        } else {
            icon.style.transform = 'rotate(0deg)'
        }
    }

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