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
    const tabName = event.currentTarget.dataset.subTab
    const currentTab = sessionStorage.getItem("activeSubTab") || this.tabTargets[0].dataset.subTab
    
    if (tabName === currentTab) return;

    const url = new URL(window.location)
    let hasFilters = false
    for (const [key, value] of url.searchParams.entries()) {
      if (!['tab', 'q', 'page', 'sort', 'direction'].includes(key)) {
        hasFilters = true
        break
      }
    }

    if (hasFilters) {
      sessionStorage.setItem("activeSubTab", tabName)
      const q = url.searchParams.get("q")
      url.search = ""
      if (q) url.searchParams.set("q", q)
      url.searchParams.set("tab", "frise")
      Turbo.visit(url.toString())
      return
    }

    this.switchTab(tabName)
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
