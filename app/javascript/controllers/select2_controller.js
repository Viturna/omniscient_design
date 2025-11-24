import { Controller } from "@hotwired/stimulus"
import $ from "jquery_provider" // On utilise notre provider sécurisé
import "select2"

export default class extends Controller {
    static values = {
        placeholder: String,
        submitOnChange: { type: Boolean, default: false } // Pour la page recherche
    }

    connect() {
        // Initialisation de Select2 sur l'élément (this.element)
        this.select = $(this.element).select2({
            placeholder: this.placeholderValue || "Sélectionner...",
            allowClear: true,
            width: '100%',
            language: {
                inputTooShort: () => "Veuillez entrer plus de caractères...",
                searching: () => "Recherche en cours...",
                noResults: () => "Aucun résultat trouvé"
            }
        });

        // Gestion des événements (sélection / désélection)
        this.select.on('select2:select select2:unselect', (e) => {
            // 1. On signale à Stimulus qu'il y a eu un changement (Select2 mange l'événement natif)
            this.element.dispatchEvent(new Event('change', { bubbles: true }));
            this.element.dispatchEvent(new Event('input', { bubbles: true }));

            // 2. Si l'option submitOnChange est activée (page recherche), on soumet le formulaire
            if (this.submitOnChangeValue) {
                this.submitForm();
            }
        });
    }

    disconnect() {
        // Nettoyage impératif pour éviter les doublons avec Turbo
        if (this.select) {
            this.select.select2('destroy');
        }
    }

    submitForm() {
        // Logique spécifique pour ta page de recherche (reproduit ton ancien script)
        const form = this.element.closest('form');
        if (form) {
            // Mise à jour de l'URL (history) comme tu le faisais
            const formData = new FormData(form);
            const url = new URL(window.location.href);

            // On nettoie les params actuels et on remet ceux du form
            // Note: C'est une simplification, adapte si tu veux garder d'autres params
            formData.forEach((value, key) => {
                if (value) url.searchParams.set(key, value);
                else url.searchParams.delete(key);
            });

            window.history.pushState({}, "", url);
            form.requestSubmit(); // Soumission compatible Turbo
        }
    }
}