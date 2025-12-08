import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["step", "prevButton", "rulesCheckbox", "rulesNextBtn", "nameInput", "surnameInput", "errorMessage", "progressBar", "progressText", "stepTitle"]

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
        this.bindHeaderBack();
    }

    disconnect() {
        if (this.boundHeaderBackHandler) {
            const backLink = document.getElementById("header-back-btn");
            if (backLink) {
                backLink.removeEventListener('click', this.boundHeaderBackHandler);
            }
        }
    }

    // --- GESTION DU HEADER (C'est cette partie qui manquait) ---

    bindHeaderBack() {
        const backLink = document.getElementById("header-back-btn");

        if (backLink) {
            this.boundHeaderBackHandler = this.handleHeaderBack.bind(this);
            backLink.addEventListener('click', this.boundHeaderBackHandler);
        }
    }

    handleHeaderBack(event) {
        // Définir le point de départ selon le mode (0 pour création, 1 pour édition)
        const startStepIndex = this.editModeValue ? 1 : 0;

        // Si on est plus loin que le début du formulaire...
        if (this.currentStepIndex > startStepIndex) {
            // ... on empêche le lien de changer de page
            event.preventDefault();
            // ... et on recule d'une étape
            this.currentStepIndex--;
            this.showCurrentStep();
        }
        // Sinon, on laisse le lien fonctionner normalement (retour à la page précédente)
    }

    // --- FIN GESTION HEADER ---

    showCurrentStep() {
        if (!this.hasStepTarget) return;

        this.stepTargets.forEach((el, index) => {
            if (index === this.currentStepIndex) {
                el.style.display = "block";
                el.style.visibility = "visible";

                this.trackStepView(index + 1);
                this.updateHeaderTitle(el);
            } else {
                el.style.display = "none";
            }
        });

        this.updateButtons();
        this.updateProgress();
        this.hideError();
        window.scrollTo(0, 0);
    }

    updateHeaderTitle(currentStepEl) {
        const headerTitle = document.querySelector(".top-header h1");

        const stepTitle = this.hasStepTitleTarget ?
            currentStepEl.querySelector('[data-multi-step-form-target="stepTitle"]') :
            currentStepEl.querySelector("h3");

        if (headerTitle && stepTitle) {
            headerTitle.textContent = stepTitle.textContent;
            stepTitle.style.display = "none";
        }
    }

    updateProgress() {
        const progressBar = document.querySelector(".progress-bar-form");
        const progressText = document.querySelector(".progress-percent-form");

        if (!progressBar) return;

        const totalSteps = this.stepTargets.length;
        const percent = Math.round((this.currentStepIndex / totalSteps) * 100);

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

        if (this.hasSurnameInputTarget && this.hasNameInputTarget) {
            const nom = this.nameInputTarget.value.trim();
            const prenom = this.surnameInputTarget.value.trim();
            params = `nom=${encodeURIComponent(nom)}&prenom=${encodeURIComponent(prenom)}`;
        }
        else if (this.hasNameInputTarget) {
            const nom = this.nameInputTarget.value.trim();

            if (this.checkUrlValue.includes("studios")) {
                params = `nom=${encodeURIComponent(nom)}`;
            } else {
                params = `nom_oeuvre=${encodeURIComponent(nom)}`;
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