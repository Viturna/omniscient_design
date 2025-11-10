import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // Assurez-vous que les targets correspondent à votre HTML
    static targets = ["statutSelect", "studentField", "establishmentField"]

    connect() {
        this.toggleFields()
    }

    // La méthode principale
    toggleFields() {
        const statut = this.statutSelectTarget.value

        // 1. Gestion des champs "Niveau d'étude" (étudiants uniquement)
        const showStudentFields = statut === "etudiant"
        if (this.hasStudentFieldTarget) {
            this.studentFieldTargets.forEach(field => {
                field.style.display = showStudentFields ? "" : "none"
                // Optionnel : rendre requis/non-requis les inputs à l'intérieur
                const input = field.querySelector('select, input')
                if (input) input.required = showStudentFields
            })
        }

        // 2. Gestion du champ "Établissement" (étudiants OU enseignants)
        const showEstablishment = statut === "etudiant" || statut === "enseignant"
        if (this.hasEstablishmentFieldTarget) {
            this.establishmentFieldTargets.forEach(field => {
                field.style.display = showEstablishment ? "" : "none"
                const input = field.querySelector('select, input')
                // On ne force pas 'required' pour l'établissement car parfois optionnel, à ajuster selon votre besoin
                if (input && showEstablishment) {
                    // input.required = true
                } else if (input) {
                    input.required = false
                    // Reset de la valeur si caché
                    input.value = ""
                }
            })
        }
    }

    // --- ALIAS POUR LA COMPATIBILITÉ HTML ---
    // C'est cette méthode que votre HTML cherche actuellement
    toggleStudentFields() {
        this.toggleFields()
    }

    // Alias au cas où votre HTML utiliserait encore l'ancien nom pour l'établissement
    toggleEstablishment() {
        this.toggleFields()
    }
}