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

    const ariaLabel = this.selectTarget.getAttribute('aria-label') || "Sélection d'utilisateurs";
    const selection = $(this.selectTarget).next('.select2-container').find('.select2-selection');
    if (selection.length) {
      selection.attr('aria-label', ariaLabel);
    }

    $(this.selectTarget).on('select2:open', () => {
      const searchField = document.querySelector('.select2-search__field');
      if (searchField) {
        searchField.setAttribute('aria-label', ariaLabel);
      }
    });
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
    const statusSelect = document.getElementById('status')
    const isStatusSelected = statusSelect && statusSelect.value !== 'all'

    if (!isAllSelected && (!selectedUsers || selectedUsers.length === 0) && !isStatusSelected) {
      event.preventDefault()
      alert("Sélectionne au moins un utilisateur, coche 'Tous les Utilisateurs', ou choisis un statut.")
    }

  }
}