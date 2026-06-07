import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    if (this.hasTabTarget) {
      this.switchTab(this.tabTargets[0].dataset.subTab)
    }
  }

  switch(event) {
    event.preventDefault()
    this.switchTab(event.currentTarget.dataset.subTab)
  }

  switchTab(tabName) {
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
