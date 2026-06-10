import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  connect() {
    // Avoid double initialization
    if ($(this.element).hasClass('select2-hidden-accessible')) return;

    // 1. Initialise Select2 sur ce <select>
    $(this.element).select2({
      placeholder: "Attribuer des notions...",
      allowClear: true,
      width: '100%',
      dropdownAutoWidth: true,
      closeOnSelect: false,
      dropdownParent: $(this.element).closest('td') // Évite les problèmes de scroll parent
    });

    const ariaLabel = this.element.getAttribute('aria-label') || "Attribuer des notions...";
    const selection = $(this.element).next('.select2-container').find('.select2-selection');
    if (selection.length) {
      selection.attr('aria-label', ariaLabel);
    }

    // 2. Écoute l'ouverture pour corriger le scroll et focus
    $(this.element).on('select2:open', () => {
      const results = document.querySelector('.select2-results__options');
      if (results) results.setAttribute('data-lenis-prevent', 'true');
      
      // Auto-focus sur le champ de recherche
      const searchField = document.querySelector('.select2-search__field');
      if (searchField) {
        searchField.setAttribute('aria-label', ariaLabel);
        searchField.focus();
        searchField.placeholder = "Tape pour chercher une notion...";
      }
    });

    // 3. Écoute l'événement natif de Select2
    $(this.element).on('change.select2', () => {
      this.save();
    });
  }

  disconnect() {
    if ($(this.element).hasClass('select2-hidden-accessible')) {
      $(this.element).select2('destroy');
    }
  }

  save() {
    const form = this.element.closest('form');
    if (!form) return;

    const url = form.getAttribute('action') || form.action;
    const formData = new FormData(form);
    const referenceId = this.element.dataset.referenceId;
    const statusBadge = document.getElementById(`status-${referenceId}`);

    if (!statusBadge) return;

    // UI : État de sauvegarde
    statusBadge.innerHTML = `<span class="spinner"></span> Sauvegarde...`;
    statusBadge.className = "badge badge-orange";

    // Envoi de la requête en tâche de fond (AJAX)
    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        'Accept': 'application/json'
      }
    })
      .then(async response => {
        const data = await response.json();
        if (response.ok && data.success) {
          this.showSuccess(statusBadge);
        } else {
          throw new Error(data.error || "Erreur lors de la sauvegarde");
        }
      })
      .catch(error => {
        console.error("Notion Assign Error:", error);
        this.showError(statusBadge);
      });
  }

  showSuccess(badge) {
    badge.textContent = "Enregistré ✓";
    badge.className = "badge badge-green";

    if (this.successTimeout) clearTimeout(this.successTimeout);
    this.successTimeout = setTimeout(() => {
      badge.textContent = "-";
      badge.className = "badge badge-gray";
    }, 2500);
  }

  showError(badge) {
    badge.textContent = "Erreur ❌";
    badge.className = "badge badge-red";
    
    setTimeout(() => {
      badge.textContent = "Réessayer";
      badge.className = "badge badge-gray";
    }, 4000);
  }
}