import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "tab", "tabContent", "tabInput",
        "notionsFilter", "countryFilter", "domainFilter", "dateFilter",
        "sortFilter", "sortSelect"
    ]

    connect() {
        this.applyFiltersDisplay()
    }

    switch(event) {
        const tabName = event.currentTarget.dataset.tab
        if (this.hasTabInputTarget) this.tabInputTarget.value = tabName
        this.showTab(tabName)

        // Construire l’URL avec le bon paramètre
        const url = new URL(window.location)
        url.searchParams.set("tab", tabName)
        url.searchParams.set("page", "1")

        // Rediriger (Turbo va recharger côté serveur)
        Turbo.visit(url.toString())
    }

    // Affiche/caché les contenus + filtres
    showTab(tabName) {
        this.tabContentTargets.forEach(tab => tab.style.display = "none")
        const activeContent = this.tabContentTargets.find(tab => tab.id === tabName)
        if (activeContent) activeContent.style.display = "block"

        this.tabTargets.forEach(tab => tab.classList.remove("active"))
        const activeButton = this.tabTargets.find(tab => tab.dataset.tab === tabName)
        if (activeButton) activeButton.classList.add("active")

        this.applyFiltersDisplay(tabName)
    }

    applyFiltersDisplay(tabName = new URLSearchParams(window.location.search).get("tab") || "designers") {
        if (this.hasDomainFilterTarget) this.domainFilterTarget.style.display = "flex"
        if (this.hasCountryFilterTarget) {
            this.countryFilterTarget.style.display = ["designers", "frise"].includes(tabName) ? "flex" : "none"
        }
        if (this.hasNotionsFilterTarget)
            this.notionsFilterTarget.style.display = ["references", "frise"].includes(tabName) ? "flex" : "none"

        if (this.hasSortFilterTarget && this.hasSortSelectTarget)
            this.updateSortOptions(tabName)
    }
    updateSortOptions(tabName) {
        if (tabName === "frise") {
            if (this.hasSortFilterTarget) this.sortFilterTarget.style.display = "none"
            return
        }

        if (this.hasSortFilterTarget) this.sortFilterTarget.style.display = "flex"

        let options = []

        if (tabName === "references") {
            options = [
                { text: window.I18nSearchSort.references.nom_asc, value: "nom_asc" },
                { text: window.I18nSearchSort.references.nom_desc, value: "nom_desc" },
                { text: window.I18nSearchSort.references.oeuvre_asc, value: "oeuvre_asc" },
                { text: window.I18nSearchSort.references.oeuvre_desc, value: "oeuvre_desc" }
            ]
        } else if (tabName === "designers") {
            options = [
                { text: window.I18nSearchSort.designers.nom_asc, value: "nom_asc" },
                { text: window.I18nSearchSort.designers.nom_desc, value: "nom_desc" },
                { text: window.I18nSearchSort.designers.naissance_asc, value: "naissance_asc" },
                { text: window.I18nSearchSort.designers.naissance_desc, value: "naissance_desc" }
            ]
        }

        if (this.hasSortSelectTarget) {
            const currentSort = new URLSearchParams(window.location.search).get("sort") || this.sortSelectTarget.value
            this.sortSelectTarget.innerHTML = ""
            options.forEach(opt => {
                const option = document.createElement("option")
                option.value = opt.value
                option.textContent = opt.text
                if (opt.value === currentSort) option.selected = true
                this.sortSelectTarget.appendChild(option)
            })
        }
    }

}
