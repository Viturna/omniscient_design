import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["step", "prevButton", "rulesCheckbox", "rulesNextBtn", "nameInput", "surnameInput", "errorMessage", "progressBar", "progressText"]

    static values = {
        editMode: Boolean,
        checkUrl: String,
        formType: String
    }

    connect() {
        this.currentStepIndex = 0;

        if (this.editModeValue) {
            this.currentStepIndex = 1;
        }

        this.showCurrentStep();
        this.checkRulesCheckbox();
    }

    showCurrentStep() {
        if (!this.hasStepTarget) return;

        this.stepTargets.forEach((el, index) => {
            if (index === this.currentStepIndex) {
                el.style.display = "block";
                el.style.visibility = "visible";

                this.trackStepView(index + 1);
            } else {
                el.style.display = "none";
            }
        });

        this.updateButtons();
        this.updateProgress();
        this.hideError();
        window.scrollTo(0, 0);
    }

    updateProgress() {
        const progressBar = document.querySelector(".progress-bar-form");
        const progressText = document.querySelector(".progress-percent-form");

        if (!progressBar) return;

        const totalSteps = this.stepTargets.length;
        const current = this.currentStepIndex + 1;
        const percent = Math.round((current / totalSteps) * 100);

        progressBar.style.width = `${percent}%`;
        if (progressText) {
            progressText.textContent = `${percent}%`;
        }
    }

    updateButtons() {
        if (this.hasPrevButtonTarget) {
            if (this.editModeValue && this.currentStepIndex === 1) {
                this.prevButtonTarget.style.display = "none";
            } else {
                this.prevButtonTarget.style.display = "inline-block";
            }
        }
    }

    async next(event) {
        event.preventDefault();
        if (!this.validateCurrentStep()) return;

        if (this.currentStepIndex === 1 && !this.editModeValue) {
            const canProceed = await this.checkExistence();
            if (!canProceed) return;
        }

        if (this.currentStepIndex < this.stepTargets.length - 1) {
            this.currentStepIndex++;
            this.showCurrentStep();
        }
    }

    prev(event) {
        event.preventDefault();
        if (this.editModeValue && this.currentStepIndex === 1) return;

        if (this.currentStepIndex > 0) {
            this.currentStepIndex--;
            this.showCurrentStep();
        }
    }

    toggleRules(event) {
        const isChecked = event.target.checked;
        if (this.hasRulesNextBtnTarget) {
            this.rulesNextBtnTarget.disabled = !isChecked;
        }
        if (isChecked) {
            sessionStorage.setItem("rulesAccepted", "true");
        }
    }

    checkRulesCheckbox() {
        if (this.hasRulesCheckboxTarget && this.hasRulesNextBtnTarget) {
            this.rulesNextBtnTarget.disabled = !this.rulesCheckboxTarget.checked;
        }
    }

    validateCurrentStep() {
        const currentStepEl = this.stepTargets[this.currentStepIndex];
        const inputs = currentStepEl.querySelectorAll("input, select, textarea");
        let isValid = true;

        for (const input of inputs) {
            if (!input.checkValidity()) {
                isValid = false;
                input.reportValidity();

                this.trackValidationError(this.currentStepIndex + 1, input.name);
                break;
            }
        }
        return isValid;
    }

    async checkExistence() {
        if (!this.hasCheckUrlValue) return true;

        let params = "";

        // Cas 1 : Designer (Nom + Prénom)
        if (this.hasSurnameInputTarget && this.hasNameInputTarget) {
            const nom = this.nameInputTarget.value.trim();
            const prenom = this.surnameInputTarget.value.trim();
            params = `nom=${encodeURIComponent(nom)}&prenom=${encodeURIComponent(prenom)}`;
        }
        // Cas 2 : Nom seul (Oeuvre ou Studio)
        else if (this.hasNameInputTarget) {
            const nom = this.nameInputTarget.value.trim();

            if (this.checkUrlValue.includes("studios")) {
                params = `nom=${encodeURIComponent(nom)}`; // Pour les Studios
            } else {
                params = `nom_oeuvre=${encodeURIComponent(nom)}`; // Par défaut (Oeuvres)
            }
        } else {
            return true;
        }

        try {
            const response = await fetch(`${this.checkUrlValue}?${params}`, {
                headers: { "Accept": "application/json" }
            });
            const data = await response.json();

            if (data.exists) {
                if (data.edit_path) {
                    window.location.href = data.edit_path;
                } else {
                    this.showError("Cette fiche existe déjà et est validée.");
                }
                return false;
            }
            return true;
        } catch (error) {
            console.error("Erreur vérification:", error);
            return true;
        }
    }

    showError(message) {
        if (this.hasErrorMessageTarget) {
            this.errorMessageTarget.textContent = message;
            this.errorMessageTarget.style.display = "block";
        } else {
            alert(message);
        }
    }

    hideError() {
        if (this.hasErrorMessageTarget) {
            this.errorMessageTarget.style.display = "none";
            this.errorMessageTarget.textContent = "";
        }
    }

    // MÉTHODES DE TRACKING GOOGLE ANALYTICS

    trackStepView(stepNumber) {
        if (typeof gtag !== 'function') return;

        const formType = this.hasFormTypeValue ? this.formTypeValue : "unknown";

        gtag('event', 'form_step_view', {
            'event_category': 'Contribution',
            'event_label': formType,
            'step_number': stepNumber,
            'form_name': `add_${formType}`
        });

    }

    trackValidationError(stepNumber, fieldName) {
        if (typeof gtag !== 'function') return;

        const formType = this.hasFormTypeValue ? this.formTypeValue : "unknown";

        gtag('event', 'form_validation_error', {
            'event_category': 'Contribution',
            'event_label': formType,
            'step_number': stepNumber,
            'error_field': fieldName
        });
    }
}