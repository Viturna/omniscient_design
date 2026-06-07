import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    if (this.hasTabTarget) {
      let savedTab = sessionStorage.getItem("activeSubTab")
      if (!savedTab || !this.tabTargets.some(t => t.dataset.subTab === savedTab)) {
        savedTab = this.tabTargets[0].dataset.subTab
      }
      this.switchTab(savedTab)
    }
  }

  switch(event) {
    event.preventDefault()
    this.switchTab(event.currentTarget.dataset.subTab)
  }

  switchTab(tabName) {
    sessionStorage.setItem("activeSubTab", tabName)
    this.tabTargets.forEach(t => {
      t.classList.toggle("active", t.dataset.subTab === tabName)
    })
    this.contentTargets.forEach(c => {
      c.style.display = (c.dataset.subTab === tabName) ? "block" : "none"
    })

    const countryFilter = document.querySelector('[data-tabs-search-target="countryFilter"]')
    if (countryFilter) {
      countryFilter.style.display = ["designers", "studios"].includes(tabName) ? "flex" : "none"
    }

    const notionsFilter = document.querySelector('[data-tabs-search-target="notionsFilter"]')
    if (notionsFilter) {
      notionsFilter.style.display = (tabName === "references") ? "flex" : "none"
    }
  }
}
