import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["establishmentSelect", "studyLevelSelect"]
  static values = {
    studyLevelsByCountry: Object,
    allLevels: Array,
    establishmentCountries: Object,
    currentLevel: String
  }

  connect() {
    this.updateStudyLevels()
  }

  onEstablishmentChange() {
    this.updateStudyLevels(true)
  }

  updateStudyLevels(resetValue = false) {
    if (!this.hasStudyLevelSelectTarget) return

    const establishmentId = this.hasEstablishmentSelectTarget ? this.establishmentSelectTarget.value : ""
    const country = (this.establishmentCountriesValue && this.establishmentCountriesValue[establishmentId]) || "FR"
    
    const levels = (this.studyLevelsByCountryValue && this.studyLevelsByCountryValue[country]) || this.allLevelsValue || []
    const currentSelected = resetValue ? "" : (this.studyLevelSelectTarget.value || this.currentLevelValue || "")

    const $select = $(this.studyLevelSelectTarget)
    $select.empty()

    const placeholder = this.studyLevelSelectTarget.dataset.select2PlaceholderValue || "Sélectionne ton niveau scolaire"
    $select.append(new Option(placeholder, "", false, false))

    levels.forEach(level => {
      const isSelected = level === currentSelected
      const option = new Option(level, level, isSelected, isSelected)
      $select.append(option)
    })

    if ($select.data('select2')) {
      $select.trigger('change.select2')
    }
  }
}
