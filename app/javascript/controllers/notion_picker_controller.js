import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "themesView", "notionsView", "themeColumn", "selectedThemeTitle", "searchInput", "searchResults", "badge"]
    static values = {
        referenceId: String,
        saveUrl: String
    }

    connect() {
        this.selectedNotionIds = new Set(JSON.parse(this.element.dataset.selectedIds || "[]"))
        this.updateBadge()
    }

    toggle() {
        const isActive = this.contentTarget.classList.toggle('active')
        if (isActive) {
            this.showThemes()
            setTimeout(() => this.searchInputTarget.focus(), 100)
        }
    }

    close() {
        this.contentTarget.classList.remove('active')
    }

    showThemes() {
        this.themesViewTarget.style.display = 'block'
        this.notionsViewTarget.style.display = 'none'
        if (this.hasSearchResultsTarget) this.searchResultsTarget.style.display = 'none'
    }

    selectTheme(event) {
        const theme = event.currentTarget.dataset.theme
        this.selectedThemeTitleTarget.textContent = theme
        
        this.themeColumnTargets.forEach(col => {
            col.style.display = col.dataset.themeName === theme ? 'block' : 'none'
        })

        this.themesViewTarget.style.display = 'none'
        this.notionsViewTarget.style.display = 'block'
    }

    backToThemes() {
        this.showThemes()
    }

    toggleNotion(event) {
        const id = event.target.value
        if (event.target.checked) {
            this.selectedNotionIds.add(id)
        } else {
            this.selectedNotionIds.delete(id)
        }
        this.save()
    }

    search(event) {
        const query = event.target.value.toLowerCase().trim()
        if (query.length === 0) {
            this.showThemes()
            return
        }

        this.themesViewTarget.style.display = 'none'
        this.notionsViewTarget.style.display = 'none'
        this.searchResultsTarget.style.display = 'block'

        const allItems = this.element.querySelectorAll('.picker-notion-item')
        this.searchResultsTarget.innerHTML = ''
        
        let hasMatch = false
        allItems.forEach(item => {
            const text = item.querySelector('span').textContent.toLowerCase()
            if (text.includes(query)) {
                const clone = item.cloneNode(true)
                const originalCheckbox = item.querySelector('input')
                const cloneCheckbox = clone.querySelector('input')
                
                cloneCheckbox.checked = this.selectedNotionIds.has(cloneCheckbox.value)
                cloneCheckbox.addEventListener('change', (e) => {
                    originalCheckbox.checked = e.target.checked
                    originalCheckbox.dispatchEvent(new Event('change', { bubbles: true }))
                })
                
                this.searchResultsTarget.appendChild(clone)
                hasMatch = true
            }
        })

        if (!hasMatch) {
            this.searchResultsTarget.innerHTML = '<p class="no-results">Aucune notion trouvée.</p>'
        }
    }

    save() {
        this.updateBadge()
        this.showSavingState()

        const formData = new FormData()
        this.selectedNotionIds.forEach(id => {
            formData.append('reference[notion_ids][]', id)
        })

        fetch(this.saveUrlValue, {
            method: 'PATCH',
            body: formData,
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.showSuccessState()
            }
        })
    }

    updateBadge() {
        const count = this.selectedNotionIds.size
        this.badgeTarget.textContent = count > 0 ? `${count} notion${count > 1 ? 's' : ''}` : "Attribuer..."
        this.badgeTarget.className = count > 0 ? "picker-badge active" : "picker-badge"
    }

    showSavingState() {
        const statusBadge = document.getElementById(`status-${this.referenceIdValue}`)
        if (statusBadge) {
            statusBadge.innerHTML = `<span class="spinner"></span>`
            statusBadge.className = "badge badge-orange"
        }
    }

    showSuccessState() {
        const statusBadge = document.getElementById(`status-${this.referenceIdValue}`)
        if (statusBadge) {
            statusBadge.textContent = "✓"
            statusBadge.className = "badge badge-green"
            setTimeout(() => {
                statusBadge.textContent = "-"
                statusBadge.className = "badge badge-gray"
            }, 2000)
        }
    }
}
