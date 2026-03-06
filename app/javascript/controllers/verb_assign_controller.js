import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  connect() {
    // 1. Initialise Select2 sur ce <select>
    $(this.element).select2({
      placeholder: "Rechercher ou ajouter des verbes...",
      allowClear: true,
      width: '100%'
    });

    // 2. Écoute l'événement natif de Select2 quand on sélectionne/désélectionne
    $(this.element).on('change', () => {
      this.save();
    });
  }

  save() {
    const form = this.element.closest('form');
    const url = form.action;
    const formData = new FormData(form);
    const referenceId = this.element.dataset.referenceId;
    const statusBadge = document.getElementById(`status-${referenceId}`);

    // UX : Changement visuel pendant la sauvegarde
    statusBadge.textContent = "Sauvegarde...";
    statusBadge.className = "badge badge-orange";

    // Envoi de la requête en tâche de fond (AJAX)
    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // UX : Confirmation de succès
          statusBadge.textContent = "Enregistré ✓";
          statusBadge.className = "badge badge-green";

          // Remise à zéro visuelle après 2 secondes
          setTimeout(() => {
            statusBadge.textContent = "-";
            statusBadge.className = "badge badge-gray";
          }, 2000);
        } else {
          throw new Error("Erreur serveur");
        }
      })
      .catch(error => {
        statusBadge.textContent = "Erreur ❌";
        statusBadge.className = "badge badge-red";
      });
  }
}