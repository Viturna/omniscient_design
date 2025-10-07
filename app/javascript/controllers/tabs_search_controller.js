// app/javascript/controllers/tabs_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "tab", "tabContent", "tabInput",
        "notionsFilter", "countryFilter", "domainFilter", "dateFilter",
        "sortFilter", "sortSelect"
    ]

    connect() {
        // applique les filtres au chargement initial
        this.applyFiltersDisplay()
    }

    /**
     * Géré au clic sur un onglet.
     * Si on reste sur le même onglet => switch local.
     * Sinon => affiche un loader puis Turbo.visit(url).
     */
    switch(event) {
        event.preventDefault()
        const tabName = event.currentTarget.dataset.tab

        if (this.hasTabInputTarget) {
            this.tabInputTarget.value = tabName
        }

        const currentTab = new URL(window.location).searchParams.get("tab") || "designers"

        if (tabName === currentTab) {
            this.showTabLocally(tabName)
            return
        }

        // feedback immédiat sur le bouton
        this.tabTargets.forEach(tab => tab.classList.remove("active"))
        event.currentTarget.classList.add("active")

        // affiche le loader
        this.showLoadingOverlay()

        // construit l’URL et déclenche le rechargement côté serveur
        const url = new URL(window.location)
        url.searchParams.set("tab", tabName)
        url.searchParams.set("page", "1")

        Turbo.visit(url.toString())


    }

    /**
     * Affichage local si on reste sur le même onglet
     */
    showTabLocally(tabName) {
        this.tabContentTargets.forEach(tab => {
            tab.style.display = (tab.id === tabName) ? "block" : "none"
        })

        this.tabTargets.forEach(tab => {
            tab.classList.toggle("active", tab.dataset.tab === tabName)
        })

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

    /**
     * Loader vidéo plein écran bloquant jusqu’au turbo:load complet
     */
    showLoadingOverlay() {
        // retire tout overlay existant
        const old = document.getElementById("search-loading-overlay")
        if (old) old.remove()

        const overlay = document.createElement("div")
        overlay.id = "search-loading-overlay"
        overlay.setAttribute("aria-hidden", "true")
        overlay.style.cssText = `
      position:fixed;
      inset:0;
      display:flex;
      align-items:center;
      justify-content:center;
      background:rgba(255,255,255,0.9);
      z-index:9999;
      pointer-events:auto;
      cursor:wait;
    `
        overlay.innerHTML = `
      <video autoplay loop muted playsinline webkit-playsinline preload="auto"
             style="max-width:200px;max-height:200px;pointer-events:none;">
        <source src="${window.loaderVideoPath}" type="video/webm">
        ${window.loaderUnsupportedText || "Votre navigateur ne supporte pas la vidéo."}
      </video>
    `

        document.body.appendChild(overlay)

        // Supprime l’overlay seulement quand la nouvelle page est prête
        document.addEventListener("turbo:load", () => {
            overlay.remove()
        }, { once: true })
    }
}
