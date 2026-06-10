import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "select2"

export default class extends Controller {
  static values = {
    placeholder: String,
    submitOnChange: Boolean
  }

  connect() {
    this.initSelect2()
  }

  disconnect() {
    if ($(this.element).data('select2')) {
      $(this.element).select2('destroy')
    }
  }

  initSelect2() {
    const options = {
      width: '100%',
      placeholder: this.placeholderValue || "Sélectionner...",
      allowClear: true,
      language: "fr",
      minimumResultsForSearch: this.element.dataset.select2MinimumResultsForSearchValue === "Infinity" ? Infinity : 0
    }

    $(this.element).select2(options)

    const ariaLabel = this.element.getAttribute('aria-label') || this.placeholderValue || "Sélection déroulante";
    const selection = $(this.element).next('.select2-container').find('.select2-selection');
    if (selection.length) {
      selection.attr('aria-label', ariaLabel);
    }

    $(this.element).on('select2:select select2:unselect', (e) => {
      this.element.dispatchEvent(new Event('change', { bubbles: true }))
    })

    $(this.element).on('select2:open', function (e) {
      const evt = document.querySelector('.select2-results__options');
      if (evt) {
        evt.setAttribute('data-lenis-prevent', 'true');
      }
      const searchField = document.querySelector('.select2-search__field');
      if (searchField) {
        searchField.setAttribute('aria-label', ariaLabel);
      }
    });
  }
}