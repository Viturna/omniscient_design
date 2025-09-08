// app/javascript/controllers/tabs_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "tabContent", "tabInput"]

  connect() {
    // Définir l'onglet actif au chargement
    const urlTab = new URLSearchParams(window.location.search).get("tab") || "all"
    this.showTab(urlTab)
  }

  switch(event) {
    const tabName = event.currentTarget.dataset.tab
    if (this.hasTabInputTarget) {
      this.tabInputTarget.value = tabName
    }
    this.showTab(tabName)
  }

  showTab(tabName) {
    // Masquer tous les contenus
    this.tabContentTargets.forEach(tab => tab.style.display = "none")

    // Afficher le contenu actif
    const activeTab = this.tabContentTargets.find(tab => tab.id === tabName)
    if (activeTab) activeTab.style.display = "block"

    // Mettre à jour les boutons
    this.tabTargets.forEach(tab => tab.classList.remove("active"))
    const activeButton = this.tabTargets.find(tab => tab.dataset.tab === tabName)
    if (activeButton) activeButton.classList.add("active")

    // Mettre à jour l'URL
    const url = new URL(window.location)
    url.searchParams.set("tab", tabName)
    window.history.pushState({}, "", url)
  }
}
