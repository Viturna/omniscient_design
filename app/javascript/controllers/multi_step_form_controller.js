import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["step", "prevButton", "rulesCheckbox", "rulesNextBtn", "nameInput", "surnameInput", "errorMessage", "progressBar", "progressText", "stepTitle", "stepIndicator", "summaryPrice", "summaryTotal", "summaryPackName"]

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
        this.bindRealtimeValidation();
        this.setupTrixCharCounters();
        this.bindFormSubmitValidation();
    }

    bindRealtimeValidation() {
        // Validation en temps réel lorsqu'on quitte un champ
        this.element.querySelectorAll("input, select, textarea").forEach(input => {
            if (input.type === "hidden" || input.type === "submit" || input.type === "button") return;

            input.addEventListener("blur", () => {
                if (!input.checkValidity()) {
                    input.reportValidity();
                }
            });
        });
    }

    bindFormSubmitValidation() {
        const form = this.element.tagName === 'FORM' ? this.element : this.element.querySelector('form');
        if (!form) return;

        form.addEventListener('submit', (e) => {
            // Vérifier presentation_generale dans tout le formulaire avant la soumission
            const presentationEditor = form.querySelector('trix-editor[input*="presentation_generale"]');
            if (presentationEditor) {
                const text = this.getTrixPlainText(presentationEditor);
                if (text.length < 200) {
                    e.preventDefault();
                    e.stopImmediatePropagation();

                    const stepEl = presentationEditor.closest('[data-multi-step-form-target="step"]');
                    if (stepEl) {
                        const stepIdx = this.stepTargets.indexOf(stepEl);
                        if (stepIdx !== -1) {
                            this.currentStepIndex = stepIdx;
                            this.showCurrentStep();
                        }
                    }
                    this.showError(`La présentation générale doit comporter au moins 200 caractères (actuellement ${text.length} caractères).`);
                    presentationEditor.classList.add('trix-invalid');
                    presentationEditor.focus();
                }
            }
        });
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

                // Réinitialiser les éditeurs Trix qui étaient cachés
                this.reinitTrixEditors(el);
            } else {
                el.style.display = "none";
            }
        });

        // Mise à jour du stepper UI premium s'il existe
        if (this.hasStepIndicatorTarget) {
            this.stepIndicatorTargets.forEach((indicator, index) => {
                indicator.classList.remove("active", "completed");
                if (index < this.currentStepIndex) {
                    indicator.classList.add("completed");
                } else if (index === this.currentStepIndex) {
                    indicator.classList.add("active");
                }
            });
        }

        this.updateButtons();
        this.updateProgress();
        this.hideError();
        window.scrollTo(0, 0);
    }

    updateSummary(event) {
        if (this.hasSummaryPriceTarget && this.hasSummaryTotalTarget) {
            const radio = event.target;
            const priceStr = radio.dataset.price;
            const packName = radio.dataset.name;

            this.summaryPriceTarget.textContent = priceStr + "€";
            this.summaryTotalTarget.textContent = priceStr + "€";

            if (this.hasSummaryPackNameTarget) {
                this.summaryPackNameTarget.textContent = packName;
            }
        }
    }

    reinitTrixEditors(stepEl) {
        stepEl.querySelectorAll('trix-editor').forEach(editor => {
            const inputId = editor.getAttribute('input');
            if (!inputId) return;

            const hiddenInput = document.getElementById(inputId);
            if (!hiddenInput) return;

            // Forcer la synchro: innerHTML = le vrai contenu tapé
            const content = editor.innerHTML;
            if (content && content.trim() !== "") {
                hiddenInput.value = content;
            }

            // Écouter les changements futurs pour garder la synchro
            if (!editor.hasAttribute('data-synced')) {
                editor.setAttribute('data-synced', 'true');
                editor.addEventListener('trix-change', () => {
                    hiddenInput.value = editor.innerHTML;
                });
            }
        });

        // Mettre à jour les compteurs de caractères sur les éditeurs visibles
        this.setupTrixCharCounters();
    }

    setupTrixCharCounters() {
        this.element.querySelectorAll('trix-editor').forEach(editor => {
            const inputId = editor.getAttribute('input');
            if (!inputId) return;

            const isPresentation = inputId.includes('presentation_generale');
            const isDescriptiveField = isPresentation ||
                inputId.includes('contexte_historique') ||
                inputId.includes('materiaux_et_innovations_techniques') ||
                inputId.includes('concept_et_inspiration') ||
                inputId.includes('dimension_esthetique') ||
                inputId.includes('impact_et_message') ||
                inputId.includes('formation_et_influences') ||
                inputId.includes('style_ou_philosophie') ||
                inputId.includes('creations_majeures') ||
                inputId.includes('heritage_et_impact');

            if (!isDescriptiveField) return;

            // Trouver ou créer l'élément de compteur
            let counterEl = editor.parentElement.querySelector(`.trix-char-counter[data-for="${inputId}"]`);
            if (!counterEl) {
                counterEl = document.createElement('div');
                counterEl.className = 'trix-char-counter';
                counterEl.setAttribute('data-for', inputId);
                editor.insertAdjacentElement('afterend', counterEl);
            }

            const updateCounter = () => {
                const text = this.getTrixPlainText(editor);
                const count = text.length;
                const min = 200;

                if (isPresentation) {
                    if (count === 0) {
                        counterEl.className = 'trix-char-counter counter-muted';
                        counterEl.innerHTML = `<span class="counter-badge">0 / ${min} caractères</span><span class="counter-info">(Min. 200 requis)</span>`;
                    } else if (count < min) {
                        counterEl.className = 'trix-char-counter counter-invalid';
                        counterEl.innerHTML = `<span class="counter-badge">${count} / ${min}</span><span class="counter-info">encore ${min - count} caractères requis</span>`;
                    } else {
                        counterEl.className = 'trix-char-counter counter-valid';
                        counterEl.innerHTML = `<span class="counter-badge">✓ ${count} caractères</span><span class="counter-info">Minimum de 200 atteint</span>`;
                        editor.classList.remove('trix-invalid');
                    }
                } else {
                    if (count === 0) {
                        counterEl.className = 'trix-char-counter counter-muted';
                        counterEl.innerHTML = `<span class="counter-badge">Optionnel</span><span class="counter-info">200 caractères min. si renseigné</span>`;
                        editor.classList.remove('trix-invalid');
                    } else if (count < min) {
                        counterEl.className = 'trix-char-counter counter-invalid';
                        counterEl.innerHTML = `<span class="counter-badge">${count} / ${min}</span><span class="counter-info">encore ${min - count} caractères requis</span>`;
                    } else {
                        counterEl.className = 'trix-char-counter counter-valid';
                        counterEl.innerHTML = `<span class="counter-badge">✓ ${count} caractères</span><span class="counter-info">Minimum de 200 atteint</span>`;
                        editor.classList.remove('trix-invalid');
                    }
                }
            };

            updateCounter();

            if (!editor.hasAttribute('data-counter-bound')) {
                editor.setAttribute('data-counter-bound', 'true');
                editor.addEventListener('trix-change', updateCounter);
                editor.addEventListener('input', updateCounter);
                editor.addEventListener('keyup', updateCounter);
            }
        });
    }

    getTrixPlainText(editor) {
        if (editor.editor && typeof editor.editor.getDocument === 'function') {
            const doc = editor.editor.getDocument();
            return doc.toString().replace(/\n+$/, '').trim();
        }
        const temp = document.createElement('div');
        temp.innerHTML = editor.innerHTML || '';
        return (temp.textContent || temp.innerText || '').trim();
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

        for (const input of inputs) {
            // Ignore hidden inputs, disabled inputs, and Trix toolbar inputs
            if (input.type === "hidden" || input.disabled || input.closest('trix-toolbar')) {
                continue;
            }

            if (!input.checkValidity()) {
                input.reportValidity();
                this.trackValidationError(this.currentStepIndex + 1, input.name);
                return false;
            }
        }

        // Validation des éditeurs Trix de l'étape courante
        const trixEditors = currentStepEl.querySelectorAll("trix-editor");
        for (const editor of trixEditors) {
            // Ignorer si le conteneur parent toggle-single-field est masqué (visibility: hidden ou display: none ou height: 0)
            const toggleContainer = editor.closest('[data-toggle-single-field-target="container"]');
            if (toggleContainer) {
                const style = window.getComputedStyle(toggleContainer);
                if (style.visibility === 'hidden' || style.display === 'none' || toggleContainer.style.visibility === 'hidden' || toggleContainer.style.height === '0' || toggleContainer.style.height === '0px') {
                    continue;
                }
            }

            const inputId = editor.getAttribute('input') || '';
            const text = this.getTrixPlainText(editor);
            const isPresentation = inputId.includes('presentation_generale');

            if (isPresentation) {
                if (text.length < 200) {
                    this.showError(`La présentation générale doit comporter au moins 200 caractères (actuellement ${text.length} caractères).`);
                    editor.classList.add('trix-invalid');
                    editor.focus();
                    this.setupTrixCharCounters();
                    this.trackValidationError(this.currentStepIndex + 1, inputId);
                    return false;
                }
            } else {
                const isDescriptiveField = inputId.includes('contexte_historique') ||
                    inputId.includes('materiaux_et_innovations_techniques') ||
                    inputId.includes('concept_et_inspiration') ||
                    inputId.includes('dimension_esthetique') ||
                    inputId.includes('impact_et_message') ||
                    inputId.includes('formation_et_influences') ||
                    inputId.includes('style_ou_philosophie') ||
                    inputId.includes('creations_majeures') ||
                    inputId.includes('heritage_et_impact');

                if (isDescriptiveField && text.length > 0 && text.length < 200) {
                    const label = editor.closest('div')?.querySelector('label')?.textContent || "Ce champ";
                    this.showError(`${label} doit comporter au moins 200 caractères ou être laissé vide (actuellement ${text.length} caractères).`);
                    editor.classList.add('trix-invalid');
                    editor.focus();
                    this.setupTrixCharCounters();
                    this.trackValidationError(this.currentStepIndex + 1, inputId);
                    return false;
                }
            }
            editor.classList.remove('trix-invalid');
        }

        this.hideError();
        return true;
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
                params = `nom_reference=${encodeURIComponent(nom)}`;
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