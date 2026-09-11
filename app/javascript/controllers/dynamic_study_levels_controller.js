import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["countrySelect", "establishmentSelect", "studyLevelSelect"]
  static values = {
    studyLevelsByCountry: Object,
    allLevels: Array,
    establishmentCountries: Object,
    countryMapping: Object,
    currentLevel: String
  }

  connect() {
    this.cacheInitialEstablishments()
    this.setupCountryListener()
    this.filterEstablishments(false)
    this.updateStudyLevels(false)
  }

  disconnect() {
    if (this._countryElement && this._boundCountryChange) {
      this._countryElement.removeEventListener('change', this._boundCountryChange)
    }
  }

  cacheInitialEstablishments() {
    if (this.hasEstablishmentSelectTarget && !this.allEstablishmentOptions) {
      this.allEstablishmentOptions = Array.from(this.establishmentSelectTarget.options).map(opt => ({
        value: opt.value,
        text: opt.text,
        country: (this.establishmentCountriesValue && this.establishmentCountriesValue[opt.value]) || "FR"
      }))
    }
  }

  setupCountryListener() {
    const countryElement = this.getCountrySelectElement()
    if (countryElement && !this._boundCountryChange) {
      this._countryElement = countryElement
      this._boundCountryChange = this.onCountryChange.bind(this)
      countryElement.addEventListener('change', this._boundCountryChange)
    }
  }

  getCountrySelectElement() {
    if (this.hasCountrySelectTarget) return this.countrySelectTarget
    return document.querySelector('select[name="user[country_id]"]') || document.querySelector('#user_country_id')
  }

  getCountryCode() {
    const countryElement = this.getCountrySelectElement()
    const countryId = countryElement ? countryElement.value : ""
    
    if (countryId && this.countryMappingValue && this.countryMappingValue[countryId]) {
      const mappedCode = this.countryMappingValue[countryId]
      if (mappedCode !== "OTHER") return mappedCode
    }

    // Fallback based on selected establishment if any
    const establishmentId = this.hasEstablishmentSelectTarget ? this.establishmentSelectTarget.value : ""
    if (establishmentId && this.establishmentCountriesValue && this.establishmentCountriesValue[establishmentId]) {
      return this.establishmentCountriesValue[establishmentId]
    }

    return "FR"
  }

  onCountryChange() {
    this.filterEstablishments(true)
    this.updateStudyLevels(true)
  }

  onEstablishmentChange() {
    this.updateStudyLevels(false)
  }

  filterEstablishments(resetSelection = false) {
    if (!this.hasEstablishmentSelectTarget || !this.allEstablishmentOptions) return

    const countryCode = this.getCountryCode()
    const currentVal = resetSelection ? "" : this.establishmentSelectTarget.value
    const $select = $(this.establishmentSelectTarget)

    $select.empty()

    const placeholder = this.establishmentSelectTarget.dataset.select2PlaceholderValue || "Rechercher un établissement..."
    $select.append(new Option(placeholder, "", false, false))

    let hasSelected = false
    this.allEstablishmentOptions.forEach(opt => {
      if (!opt.value) return
      if (opt.country === countryCode || countryCode === "OTHER") {
        const isSelected = !resetSelection && opt.value === currentVal
        if (isSelected) hasSelected = true
        $select.append(new Option(opt.text, opt.value, isSelected, isSelected))
      }
    })

    if (!hasSelected && !resetSelection && currentVal) {
      $select.val("")
    }

    if ($select.data('select2')) {
      $select.trigger('change.select2')
    }
  }

  updateStudyLevels(resetValue = false) {
    if (!this.hasStudyLevelSelectTarget) return

    const establishmentId = this.hasEstablishmentSelectTarget ? this.establishmentSelectTarget.value : ""
    const estCountry = (this.establishmentCountriesValue && this.establishmentCountriesValue[establishmentId])
    const country = estCountry || this.getCountryCode() || "FR"
    
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
