import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "button"]

  connect() {
    this.initialRowsToShow = 10
    this.rowsToShow = this.initialRowsToShow
    this.hideExtraRows()
  }

  hideExtraRows() {
    this.rowTargets.forEach((row, index) => {
      row.style.display = index < this.rowsToShow ? "" : "none"
    })
  }

  showMoreRows() {
    const totalRows = this.rowTargets.length
    const nextLimit = this.rowsToShow + this.initialRowsToShow

    for (let i = this.rowsToShow; i < nextLimit && i < totalRows; i++) {
      this.rowTargets[i].style.display = ""
    }

    this.rowsToShow = Math.min(nextLimit, totalRows)

    if (this.rowsToShow >= totalRows) {
      this.buttonTarget.disabled = true
      this.buttonTarget.textContent = "Toutes les lignes sont chargées"
    }
  }
}
