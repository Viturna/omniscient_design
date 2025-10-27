import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["statutSelect", "establishmentField"]

    static values = { triggers: Array }

    connect() {
        if (this.triggersValue.length === 0) {
            this.triggersValue = ["etudiant", "enseignant"]
        }

        this.toggleEstablishment()
    }

    toggleEstablishment() {
        const selectedStatut = this.statutSelectTarget.value
        const shouldShow = this.triggersValue.includes(selectedStatut)

        const field = this.establishmentFieldTarget
        const select = field.querySelector('select')

        if (shouldShow) {
            field.style.display = 'flex'
            select.required = true
        } else {
            field.style.display = 'none'
            select.required = false
            select.value = ''
            if ($(select).data('select2')) {
                $(select).val('').trigger('change')
            }
        }
    }
}
