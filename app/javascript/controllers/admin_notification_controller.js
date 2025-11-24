import { Controller } from "@hotwired/stimulus"
import $ from "jquery_provider" // On utilise ton jQuery configuré
import "select2"

export default class extends Controller {
  static targets = ["select", "checkbox", "form"]

  connect() {
    this.initSelect2()
    this.toggleSelection() // État initial
  }

  disconnect() {
    if (this.select) {
      this.select.select2('destroy')
    }
  }

  initSelect2() {
    this.select = $(this.selectTarget).select2({
      placeholder: "Rechercher et sélectionner un ou plusieurs utilisateurs...",
      allowClear: true,
      width: '100%',
      language: {
        searching: () => "Recherche en cours...",
        noResults: () => "Aucun résultat trouvé"
      }
    })
  }

  toggleSelection() {
    const isAllSelected = this.checkboxTarget.checked

    if (isAllSelected) {
      $(this.selectTarget).val(null).trigger('change')
      $(this.selectTarget).prop('disabled', true)
    } else {
      $(this.selectTarget).prop('disabled', false)
    }
  }

  submit(event) {
    const isAllSelected = this.checkboxTarget.checked
    const selectedUsers = $(this.selectTarget).val()

    if (!isAllSelected && (!selectedUsers || selectedUsers.length === 0)) {
      event.preventDefault()
      alert("Veuillez sélectionner au moins un utilisateur ou cocher 'Tous les Utilisateurs'.")
    }

  }
}