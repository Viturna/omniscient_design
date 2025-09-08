// app/javascript/controllers/tabs_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "tab",
        "tabContent",
        "tabInput",
        "notionsFilter",
        "countryFilter",
        "sortFilter",
        "sortSelect"
    ]

    connect() {
        const activeTab = new URLSearchParams(window.location.search).get("tab") || "designers"
        this.showTab(activeTab)
    }

    switch(event) {
        const tabName = event.currentTarget.dataset.tab
        if (this.hasTabInputTarget) {
            this.tabInputTarget.value = tabName
        }
        this.showTab(tabName)

        // mettre à jour le turbo-frame
        const url = new URL(window.location)
        url.searchParams.set("tab", tabName)
        url.searchParams.set("page", 1)

        const frame = document.getElementById("search-results")
        if (frame) {
            frame.src = url.toString() // recharge uniquement le contenu du frame
        }
    }
    showTab(tabName) {
        // === Affichage onglets ===
        this.tabContentTargets.forEach(tab => tab.style.display = "none")
        const activeContent = this.tabContentTargets.find(tab => tab.id === tabName)
        if (activeContent) activeContent.style.display = "block"

        this.tabTargets.forEach(tab => tab.classList.remove("active"))
        const activeButton = this.tabTargets.find(tab => tab.dataset.tab === tabName)
        if (activeButton) activeButton.classList.add("active")

        // === URL et pagination ===
        const url = new URL(window.location)
        url.searchParams.set("tab", tabName)
        url.searchParams.set("page", 1)
        window.history.pushState({}, "", url)

        // === Filtres ===
        if (this.hasNotionsFilterTarget) {
            this.notionsFilterTarget.style.display = tabName === "designers" ? "none" : "flex"
        }
        if (this.hasCountryFilterTarget) {
            this.countryFilterTarget.style.display = tabName === "references" ? "none" : "flex"
        }

        // === Sort select ===
        if (this.hasSortFilterTarget && this.hasSortSelectTarget) {
            this.updateSortOptions(tabName)
        }
    }

    updateSortOptions(tabName) {
        if (tabName === "frise") {
            this.sortFilterTarget.style.display = "none"
            return
        }

        this.sortFilterTarget.style.display = "flex"

        let options = []
        if (tabName === "references") {
            options = [
                { text: "Nom A-Z", value: "nom_asc" },
                { text: "Nom Z-A", value: "nom_desc" },
                { text: "Date œuvre (ancien → récent)", value: "oeuvre_asc" },
                { text: "Date œuvre (récent → ancien)", value: "oeuvre_desc" },
            ]
        } else if (tabName === "designers") {
            options = [
                { text: "Nom A-Z", value: "nom_asc" },
                { text: "Nom Z-A", value: "nom_desc" },
                { text: "Date naissance (ancien → récent)", value: "naissance_asc" },
                { text: "Date naissance (récent → ancien)", value: "naissance_desc" },
            ]
        }

        const urlParams = new URLSearchParams(window.location.search)
        const currentSort = urlParams.get("sort") || this.sortSelectTarget.value

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
