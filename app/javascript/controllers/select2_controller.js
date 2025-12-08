import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "select2"

export default class extends Controller {
    static values = { placeholder: String }

    connect() {
        this.initSelect2()
    }

    disconnect() {
        $(this.element).select2('destroy')
    }

    initSelect2() {
        const options = {
            width: '100%',
            placeholder: this.placeholderValue || "Sélectionner...",
            allowClear: true,
            language: "fr"
        }

        $(this.element).select2(options)

        $(this.element).on('select2:open', function (e) {
            const evt = document.querySelector('.select2-results__options');

            if (evt) {
                evt.setAttribute('data-lenis-prevent', 'true');
            }
        });
    }
}