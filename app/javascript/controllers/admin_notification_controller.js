import { Controller } from "@hotwired/stimulus"
import $ from "jquery_provider"
import "select2"

export default class extends Controller {
  static targets = ["select", "checkbox", "status", "studyLevel", "segmentBlock", "customBlock", "optionAll", "optionSegment", "optionCustom"]

  connect() {
    this.initSelect2()
    this.syncTargetMode("all")
  }

  disconnect() {
    if (this.hasSelectTarget && $(this.selectTarget).data('select2')) {
      $(this.selectTarget).select2('destroy')
    }
  }

  initSelect2() {
    if (!this.hasSelectTarget) return

    $(this.selectTarget).select2({
      placeholder: "Rechercher par prénom, nom ou email...",
      allowClear: true,
      width: '100%',
      language: {
        searching: () => "Recherche...",
        noResults: () => "Aucun utilisateur trouvé"
      }
    })

    const ariaLabel = this.selectTarget.getAttribute('aria-label') || "Membres destinataires"
    const selection = $(this.selectTarget).next('.select2-container').find('.select2-selection')
    if (selection.length) {
      selection.attr('aria-label', ariaLabel)
    }

    $(this.selectTarget).on('select2:open', () => {
      const searchField = document.querySelector('.select2-search__field')
      if (searchField) {
        searchField.setAttribute('aria-label', ariaLabel)
      }
    })
  }

  changeTargetMode(event) {
    const mode = event.currentTarget.dataset.mode || event.currentTarget.querySelector('input[type="radio"]')?.value || 'all'
    this.syncTargetMode(mode)
  }

  syncTargetMode(mode) {
    // Reset active classes on option cards
    if (this.hasOptionAllTarget) this.optionAllTarget.classList.toggle("active", mode === "all")
    if (this.hasOptionSegmentTarget) this.optionSegmentTarget.classList.toggle("active", mode === "segment")
    if (this.hasOptionCustomTarget) this.optionCustomTarget.classList.toggle("active", mode === "custom")

    // Radio button sync
    const radio = this.element.querySelector(`input[name="target_mode"][value="${mode}"]`)
    if (radio) radio.checked = true

    if (mode === "all") {
      if (this.hasCheckboxTarget) {
        this.checkboxTarget.checked = true
        this.checkboxTarget.disabled = false
      }
      if (this.hasSegmentBlockTarget) this.segmentBlockTarget.style.display = "none"
      if (this.hasCustomBlockTarget) this.customBlockTarget.style.display = "none"
      if (this.hasStatusTarget) this.statusTarget.value = "all"
      if (this.hasSelectTarget) {
        $(this.selectTarget).val(null).trigger("change")
        $(this.selectTarget).prop("disabled", true)
      }
    } else if (mode === "segment") {
      if (this.hasCheckboxTarget) {
        this.checkboxTarget.checked = false
        this.checkboxTarget.disabled = true
      }
      if (this.hasSegmentBlockTarget) this.segmentBlockTarget.style.display = "block"
      if (this.hasCustomBlockTarget) this.customBlockTarget.style.display = "none"
      if (this.hasSelectTarget) {
        $(this.selectTarget).val(null).trigger("change")
        $(this.selectTarget).prop("disabled", true)
      }
    } else if (mode === "custom") {
      if (this.hasCheckboxTarget) {
        this.checkboxTarget.checked = false
        this.checkboxTarget.disabled = true
      }
      if (this.hasSegmentBlockTarget) this.segmentBlockTarget.style.display = "none"
      if (this.hasCustomBlockTarget) {
        this.customBlockTarget.style.display = "block"
      }
      if (this.hasStatusTarget) this.statusTarget.value = "all"
      if (this.hasSelectTarget) {
        $(this.selectTarget).prop("disabled", false)
        // Refresh Select2 display width when container becomes visible
        setTimeout(() => {
          if (!$(this.selectTarget).data('select2')) {
            this.initSelect2()
          } else {
            $(this.selectTarget).select2('destroy')
            this.initSelect2()
          }
        }, 50)
      }
    }
  }

  statusChanged() {
    if (!this.hasStatusTarget || !this.hasStudyLevelTarget) return
    const isEtudiant = this.statusTarget.value === "etudiant"
    const studyLevelContainer = document.getElementById("study-level-container")
    if (studyLevelContainer) {
      studyLevelContainer.style.display = isEtudiant ? "block" : "none"
    }
    if (!isEtudiant && this.hasStudyLevelTarget) {
      this.studyLevelTarget.value = "all"
    }
  }

  submit(event) {
    const activeRadio = this.element.querySelector('input[name="target_mode"]:checked')
    const mode = activeRadio ? activeRadio.value : "all"

    if (mode === "custom") {
      const selectedUsers = $(this.selectTarget).val()
      if (!selectedUsers || selectedUsers.length === 0) {
        event.preventDefault()
        alert("Veuillez sélectionner au moins un membre destinataire dans la liste.")
        return false
      }
    } else if (mode === "segment") {
      const statusVal = this.hasStatusTarget ? this.statusTarget.value : "all"
      if (statusVal === "all" || !statusVal) {
        event.preventDefault()
        alert("Veuillez sélectionner un statut professionnel valide.")
        return false
      }
    }
  }
}