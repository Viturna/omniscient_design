import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "content",
        "label",
        "button",
        "themesView",
        "notionsView",
        "searchView",
        "searchResults",
        "themeColumn",
        "selectedThemeTitle"
    ]

    connect() {
        this.updateLabel()
        this.clickOutsideHandler = (e) => {
            if (!this.element.contains(e.target)) {
                this.contentTarget.classList.remove('active')
                this.buttonTarget.classList.remove('active')
                document.body.style.overflow = '';
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

    connect() {
        this.updateLabel();
        this.element.querySelectorAll('.mega-menu-item input[type="checkbox"]').forEach(checkbox => {
            checkbox.closest('.mega-menu-item').classList.toggle('is-checked', checkbox.checked);
        });
    }

    toggle(event) {
        event.preventDefault()
        const isActive = this.contentTarget.classList.toggle('active')
        this.buttonTarget.classList.toggle('active')

        if (isActive) {
            document.body.style.overflow = 'hidden';

            setTimeout(() => {
                const searchInput = this.element.querySelector('.mega-menu-search-input');
                if (searchInput) searchInput.focus();
            }, 100);
        } else {
            document.body.style.overflow = '';
            this.showThemes();
        }
    }

    showThemes() {
        this.notionsViewTarget.style.display = 'none';
        if (this.hasSearchViewTarget) this.searchViewTarget.style.display = 'none';
        this.themesViewTarget.style.display = 'block';
    }

    // --- NAVIGATION THEMES <-> NOTIONS ---

    selectTheme(event) {
        const themeName = event.currentTarget.dataset.themeName;
        this.themesViewTarget.style.display = 'none';
        this.selectedThemeTitleTarget.innerText = themeName;

        this.themeColumnTargets.forEach(column => {
            column.style.display = (column.dataset.themeName === themeName) ? 'grid' : 'none';
        });

        this.notionsViewTarget.style.display = 'block';
    }

    backToThemes() {
        this.showThemes();
    }

    search(event) {
        const query = event.target.value.toLowerCase().trim();

        if (query.length === 0) {
            this.showThemes();
            return;
        }

        // Cacher les autres vues
        this.themesViewTarget.style.display = 'none';
        this.notionsViewTarget.style.display = 'none';
        this.searchViewTarget.style.display = 'block';

        // Filtrer les notions
        const allNotions = this.element.querySelectorAll('.mega-menu-item');
        let hasMatch = false;

        this.searchResultsTarget.innerHTML = '';

        const matches = [];
        allNotions.forEach(item => {
            const labelText = item.querySelector('span').innerText;
            const text = labelText.toLowerCase();
            if (text.includes(query)) {
                const clone = item.cloneNode(true);
                const originalCheckbox = item.querySelector('input');
                const cloneCheckbox = clone.querySelector('input');

                // Sync state from original to clone
                cloneCheckbox.checked = originalCheckbox.checked;
                cloneCheckbox.removeAttribute('name'); // Éviter les doublons à la soumission du form

                // Sync state from clone to original when changed
                cloneCheckbox.addEventListener('change', (e) => {
                    originalCheckbox.checked = e.target.checked;
                    originalCheckbox.dispatchEvent(new Event('change', { bubbles: true }));
                    this.updateLabel();
                });

                matches.push(clone);
                hasMatch = true;
            }
        });

        if (hasMatch) {
            matches.forEach(m => this.searchResultsTarget.appendChild(m));
        } else {
            this.searchResultsTarget.innerHTML = '<p class="no-results">Aucune notion trouvée.</p>';
        }
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

    clear(event) {
        if (event) event.preventDefault();

        // Décocher tout
        this.element.querySelectorAll('.mega-menu-item input[type="checkbox"]').forEach(checkbox => {
            checkbox.checked = false;
            checkbox.closest('.mega-menu-item').classList.remove('is-checked');
        });

        // Mettre à jour le label du bouton principal
        this.updateLabel();
    }

    updateLabel(event) {
        if (event && event.target && event.target.type === 'checkbox') {
            event.target.closest('.mega-menu-item').classList.toggle('is-checked', event.target.checked);
        }

        const checkboxes = this.element.querySelectorAll('.mega-menu-grid input[type="checkbox"]:checked');
        const count = checkboxes.length;

        if (this.hasLabelTarget) {
            if (count > 0) {
                this.labelTarget.innerText = `${count} notion${count > 1 ? 's' : ''}`;
                this.buttonTarget.classList.add('has-selection');
            } else {
                this.labelTarget.innerText = "Choisir des notions";
                this.buttonTarget.classList.remove('has-selection');
            }
        }
    }
}