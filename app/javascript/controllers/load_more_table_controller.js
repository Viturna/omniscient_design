import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "button"]

  connect() {
    this.initialRowsToShow = 10
    this.rowsToShow = this.initialRowsToShow
    this.updateVisibility()
  }

  updateVisibility() {
    // Get all rows currently matching filter (or all rows if no filter)
    const allRows = this.rowTargets
    const filterQuery = this.element.querySelector(".search-input")?.value?.toLowerCase() || ""
    const filterUser = this.element.querySelector(".filter-user")?.value?.toLowerCase() || ""

    let matchingRowsCount = 0

    allRows.forEach((row) => {
      const textMatch = !filterQuery || row.innerText.toLowerCase().includes(filterQuery)
      const userCell = row.cells[2]?.innerText.toLowerCase() || ""
      const userMatch = !filterUser || userCell.includes(filterUser)

      if (textMatch && userMatch) {
        if (matchingRowsCount < this.rowsToShow) {
          row.style.display = ""
        } else {
          row.style.display = "none"
        }
        matchingRowsCount++
      } else {
        row.style.display = "none"
      }
    })

    if (this.hasButtonTarget) {
      if (this.rowsToShow >= matchingRowsCount || matchingRowsCount === 0) {
        this.buttonTarget.disabled = true
        this.buttonTarget.textContent = matchingRowsCount === 0 ? "Aucun résultat" : "Toutes les lignes sont affichées"
      } else {
        this.buttonTarget.disabled = false
        this.buttonTarget.textContent = "Voir plus (" + (matchingRowsCount - this.rowsToShow) + " restants)"
      }
    }
  }

  showMoreRows() {
    this.rowsToShow += this.initialRowsToShow
    this.updateVisibility()
  }
}

