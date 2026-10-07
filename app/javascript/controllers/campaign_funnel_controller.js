import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    checkoutUrl: String,
    userSignedIn: Boolean
  }

  static targets = [
    // Step panels
    "stepPanel",
    "stepBadge",
    "stepSubtitle",
    "prevBtn",
    "nextBtn",
    "nextBtnText",
    
    // Step 1 : Formules, Visuels & Preview
    "planCard",
    "monopoleBox",
    "monopoleForm",
    "monopoleSuccess",
    "standardFields",
    "monopoleSchoolInput",
    "monopoleEmailInput",
    "monopoleMessageInput",
    "formatPill",
    "devicePill",
    "imageInput",
    "imageMobileInput",
    "dropzone",
    "uploadPlaceholder",
    "uploadSuccess",
    "uploadFileName",
    "titleInput",
    "descInput",
    "linkInput",
    "previewFrame",
    "previewFrameAccueil",
    "previewFrameRecherche",
    "previewFrameQuiz",
    "previewFormatTag",
    "previewImage",
    "previewEmptyState",
    "previewVideo",
    "previewImageBg",
    "previewVideoBg",
    "previewTitle",
    "previewDesc",
    "previewSearchImage",
    "previewSearchVideo",
    "previewSearchTitle",
    "previewQuizImage",
    "previewQuizVideo",
    "previewQuizTitle",
    "previewQuizDesc",
    "previewDeviceLabel",
    "dimensionLabel",
    "desktopStatusDot",
    "mobileStatusDot",
    "uploadContextLabel",
    
    // Step 2 : Calendrier & Mois
    "startDateInput",
    "endDateInput",
    "calendarMonthYear",
    "calendarDaysGrid",
    "durationSummary",
    "priceSummary",
    "selectedMonthName",
    "selectedMonthPeriod",
    "monthsPillsContainer",
    
    // Step 3 : Ancrage Local & Map
    "regionSearchInput",
    "regionChip",
    "regionPath",
    "studentCount",
    "mapTooltip",
    "tooltipRegion",
    "tooltipCount",
    "tooltipPercent",
    
    // Step 4 : Compte & Informations
    "schoolNameInput",
    "domainInput",
    "emailInput",
    "passwordInput",
    "passwordConfirmInput",
    "cgvCheckbox",
    "connectedUserSection",
    "otherAccountSection",
    "otherSchoolNameInput",
    "otherDomainInput",
    "otherEmailInput",
    "otherPasswordInput",
    "otherPasswordConfirmInput"
  ]

connect() {
  this.currentStep = 1
  this.totalSteps = 4
  this.useOtherAccount = false
  
  // Form data state
  this.selectedPlan = "ancrage_local"
  this.selectedFormat = "accueil"
  this.selectedDevice = "pc"
  this.selectedRegionKeys = new Set(["cvl"]) // Centre-Val de Loire sélectionné par défaut
  this.selectedFile = null
  this.selectedMobileFile = null
  
  // Calendar state (Exactement 1 mois à partir de J+2 par défaut pour délai de modération)
  const today = new Date()
  const todayNormalized = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  this.today = todayNormalized

  const minStartDate = new Date(todayNormalized)
  minStartDate.setDate(minStartDate.getDate() + 2)
  this.minStartDate = minStartDate

  this.currentDate = new Date(minStartDate.getFullYear(), minStartDate.getMonth(), 1)
  this.rangeStart = new Date(minStartDate)
  // Exactement 30 jours par défaut (du jour J au jour J+29 inclus = 30 jours)
  const defaultEndDate = new Date(minStartDate)
  defaultEndDate.setDate(defaultEndDate.getDate() + 29)
  this.rangeEnd = defaultEndDate
  this.monthSelectionInProgress = false

  // Check URL parameters (e.g. ?plan=encart_natif or ?plan=test_2eur or ?plan=monopole)
  const urlParams = new URLSearchParams(window.location.search)
  const paramPlan = urlParams.get("plan")
  if (paramPlan && ["test_2eur", "encart_natif", "ancrage_local", "monopole"].includes(paramPlan)) {
    this.selectedPlan = paramPlan
  }
  
  // Initial renders
  this.setPlan(this.selectedPlan)
  this.updateStepView()
  this.renderCalendar()
  this.updateDatesDisplay()
  this.updateRegionsView()
}

  // =========================================================================
  // 1. GESTION DES ÉTAPES (NAVIGATION & VALIDATION)
  // =========================================================================

  get isEncartNatif() {
    return this.selectedPlan === "encart_natif" || this.selectedPlan === "test_2eur"
  }

  nextStep() {
    if (this.currentStep === 1 && this.selectedPlan === "monopole") {
      this.submitMonopoleQuote()
      return
    }

    if (!this.validateCurrentStep()) {
      return
    }

    if (this.currentStep === 2 && this.isEncartNatif) {
      // Passer directement à la création de compte (étape 4)
      this.currentStep = 4
      this.updateStepView()
    } else if (this.currentStep < 4) {
      this.currentStep++
      this.updateStepView()
    } else {
      this.submitCheckout()
    }
  }

  prevStep() {
    if (this.currentStep === 4 && this.isEncartNatif) {
      // Revenir directement au calendrier (étape 2)
      this.currentStep = 2
      this.updateStepView()
    } else if (this.currentStep > 1) {
      this.currentStep--
      this.updateStepView()
    }
  }

  validateCurrentStep() {
    this.clearAllErrors()

    if (this.currentStep === 1) {
      let isValid = true
      const title = this.hasTitleInputTarget ? this.titleInputTarget.value.trim() : ""
      const desc = this.hasDescInputTarget ? this.descInputTarget.value.trim() : ""
      let link = this.hasLinkInputTarget ? this.linkInputTarget.value.trim() : ""

      if (!link) {
        this.setFieldError(this.hasLinkInputTarget ? this.linkInputTarget : null, "Veuillez renseigner un lien de redirection.")
        isValid = false
      } else {
        // Auto-correction : ajouter https:// si l'utilisateur a écrit "monsite.fr" ou "www.monsite.fr"
        if (!link.startsWith("http://") && !link.startsWith("https://")) {
          link = `https://${link}`
          if (this.hasLinkInputTarget) this.linkInputTarget.value = link
        }

        // Validation du format d'URL
        try {
          const parsedUrl = new URL(link)
          if (!parsedUrl.hostname || !parsedUrl.hostname.includes(".")) {
            this.setFieldError(this.hasLinkInputTarget ? this.linkInputTarget : null, "Veuillez entrer une URL valide (ex : https://www.votre-ecole.fr).")
            isValid = false
          }
        } catch (_) {
          this.setFieldError(this.hasLinkInputTarget ? this.linkInputTarget : null, "Format de lien invalide (ex attendu : https://www.votre-ecole.fr).")
          isValid = false
        }
      }

      if (!desc) {
        this.setFieldError(this.hasDescInputTarget ? this.descInputTarget : null, "Veuillez renseigner une description pour votre campagne.")
        isValid = false
      }

      if (!title) {
        this.setFieldError(this.hasTitleInputTarget ? this.titleInputTarget : null, "Veuillez renseigner un titre pour votre campagne.")
        isValid = false
      }

      if (!this.selectedFile) {
        if (this.hasDropzoneTarget) {
          this.setFieldError(this.dropzoneTarget, "Veuillez importer le visuel Desktop (PC) de votre campagne.")
        }
        isValid = false
      }

      return isValid
    } else if (this.currentStep === 2) {
      if (!this.rangeStart || !this.rangeEnd) {
        if (this.hasStartDateInputTarget) {
          this.setFieldError(this.startDateInputTarget, "Veuillez sélectionner votre date de début et de fin sur le calendrier.")
        }
        return false
      }
      const minDate = this.minStartDate || this.today
      if (this.rangeStart < minDate) {
        if (this.hasStartDateInputTarget) {
          this.setFieldError(this.startDateInputTarget, "La date de début doit être au minimum dans 2 jours (délai de validation des visuels).")
        }
        return false
      }
      const startMid = new Date(this.rangeStart.getFullYear(), this.rangeStart.getMonth(), this.rangeStart.getDate())
      const endMid = new Date(this.rangeEnd.getFullYear(), this.rangeEnd.getMonth(), this.rangeEnd.getDate())
      const daysCount = Math.round((endMid - startMid) / (1000 * 60 * 60 * 24)) + 1
      if (daysCount < 7) {
        if (this.hasEndDateInputTarget) {
          this.setFieldError(this.endDateInputTarget, "La durée minimale d'une campagne est de 7 jours.")
        }
        return false
      }
    } else if (this.currentStep === 4) {
      let isValid = true
      
      const isOther = this.useOtherAccount && this.hasOtherAccountSectionTarget
      const schoolName = isOther
        ? (this.hasOtherSchoolNameInputTarget ? this.otherSchoolNameInputTarget.value.trim() : "")
        : (this.hasSchoolNameInputTarget ? this.schoolNameInputTarget.value.trim() : "")
      const domain = isOther
        ? (this.hasOtherDomainInputTarget ? this.otherDomainInputTarget.value : "")
        : (this.hasDomainInputTarget ? this.domainInputTarget.value : "")
      const email = isOther
        ? (this.hasOtherEmailInputTarget ? this.otherEmailInputTarget.value.trim() : "")
        : (this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : "")
      const password = isOther
        ? (this.hasOtherPasswordInputTarget ? this.otherPasswordInputTarget.value : "")
        : (this.hasPasswordInputTarget ? this.passwordInputTarget.value : "")
      const confirmPassword = isOther
        ? (this.hasOtherPasswordConfirmInputTarget ? this.otherPasswordConfirmInputTarget.value : "")
        : (this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget.value : "")

      // Si un mot de passe est saisi OU si le mot de passe est requis
      if (password && password !== "signed_in_pass_placeholder") {
        if (confirmPassword && password !== confirmPassword) {
          const target = isOther && this.hasOtherPasswordConfirmInputTarget ? this.otherPasswordConfirmInputTarget : (this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget : null)
          this.setFieldError(target, "Les mots de passe ne correspondent pas.")
          isValid = false
        } else {
          // Validation stricte Omniscient (min 6 car., 1 maj, 1 min, 1 chiffre, 1 car. spécial)
          const pwdRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_]).{6,}$/
          if (!pwdRegex.test(password)) {
            const target = isOther && this.hasOtherPasswordInputTarget ? this.otherPasswordInputTarget : this.passwordInputTarget
            this.setFieldError(target, "Le mot de passe doit comporter au moins 6 caractères, 1 majuscule, 1 minuscule, 1 chiffre et 1 caractère spécial.")
            isValid = false
          }
        }
      } else if (isOther) {
        if (!password) {
          this.setFieldError(this.otherPasswordInputTarget, "Veuillez renseigner le mot de passe de ce compte.")
          isValid = false
        }
      } else if (this.hasPasswordInputTarget && this.passwordInputTarget.hasAttribute("required")) {
        this.setFieldError(this.passwordInputTarget, "Veuillez renseigner un mot de passe.")
        isValid = false
      }

      if (!email || !email.includes("@")) {
        const target = isOther && this.hasOtherEmailInputTarget ? this.otherEmailInputTarget : (this.hasEmailInputTarget ? this.emailInputTarget : null)
        this.setFieldError(target, "Veuillez renseigner une adresse email valide.")
        isValid = false
      }

      if (!domain) {
        const target = isOther && this.hasOtherDomainInputTarget ? this.otherDomainInputTarget : (this.hasDomainInputTarget ? this.domainInputTarget : null)
        this.setFieldError(target, "Veuillez choisir un domaine d'activité.")
        isValid = false
      }

      if (!schoolName) {
        const target = isOther && this.hasOtherSchoolNameInputTarget ? this.otherSchoolNameInputTarget : (this.hasSchoolNameInputTarget ? this.schoolNameInputTarget : null)
        this.setFieldError(target, "Veuillez renseigner le nom de votre établissement ou entreprise.")
        isValid = false
      }

      if (this.hasCgvCheckboxTarget && !this.cgvCheckboxTarget.checked) {
        this.setFieldError(this.cgvCheckboxTarget, "Veuillez accepter les Conditions Générales de Vente pour continuer.")
        isValid = false
      }

      return isValid
    }

    return true
  }

  setFieldError(inputEl, message) {
    if (!inputEl) return
    inputEl.classList.add("sa-funnel__input--error")
    if (inputEl.classList.contains("sa-upload-box")) {
      inputEl.classList.add("sa-upload-box--error")
    }

    const fieldContainer = inputEl.closest(".sa-funnel__field") || inputEl.closest(".sa-funnel__form-group") || inputEl.parentElement
    if (fieldContainer) {
      const existingError = fieldContainer.querySelector(".sa-funnel__field-error")
      if (existingError) existingError.remove()

      if (message) {
        const errorEl = document.createElement("span")
        errorEl.className = "sa-funnel__field-error"
        errorEl.textContent = message
        fieldContainer.appendChild(errorEl)
      }
    }

    inputEl.focus()
    inputEl.scrollIntoView({ behavior: "smooth", block: "center" })

    const clearHandler = () => {
      this.clearFieldError(inputEl)
      inputEl.removeEventListener("input", clearHandler)
      inputEl.removeEventListener("change", clearHandler)
      inputEl.removeEventListener("click", clearHandler)
    }
    inputEl.addEventListener("input", clearHandler)
    inputEl.addEventListener("change", clearHandler)
    inputEl.addEventListener("click", clearHandler)
  }

  clearErrorOnInput(event) {
    if (event?.currentTarget) {
      this.clearFieldError(event.currentTarget)
    }
  }

  clearFieldError(inputEl) {
    if (!inputEl) return
    inputEl.classList.remove("sa-funnel__input--error", "sa-funnel__textarea--error", "sa-funnel__select--error", "sa-upload-box--error")
    const fieldContainer = inputEl.closest(".sa-funnel__field") || inputEl.closest(".sa-funnel__form-group") || inputEl.parentElement
    if (fieldContainer) {
      const existingError = fieldContainer.querySelector(".sa-funnel__field-error")
      if (existingError) existingError.remove()
    }
  }

  clearAllErrors() {
    this.element.querySelectorAll(".sa-funnel__input--error, .sa-funnel__textarea--error, .sa-funnel__select--error, .sa-upload-box--error").forEach(el => {
      el.classList.remove("sa-funnel__input--error", "sa-funnel__textarea--error", "sa-funnel__select--error", "sa-upload-box--error")
    })
    this.element.querySelectorAll(".sa-funnel__field-error").forEach(el => el.remove())
  }

  updateStepView() {
    // 1. Switch left form panels
    this.stepPanelTargets.forEach(panel => {
      const panelStep = parseInt(panel.dataset.step)
      panel.classList.toggle("sa-funnel__panel--active", panelStep === this.currentStep)
    })

    // 2. Update Header Titles & CTA Text
    const isEncart = this.isEncartNatif
    const totalCount = isEncart ? 3 : 4
    const displayStepNum = (this.currentStep === 4 && isEncart) ? 3 : this.currentStep

    const stepConfig = {
      1: {
        badge: `Étape 1/${totalCount} : Visuels`,
        subtitle: "Configuration des visuels de votre campagne",
        nextText: "Calendrier de diffusion",
        showPrev: false
      },
      2: {
        badge: `Étape 2/${totalCount} : Calendrier de diffusion`,
        subtitle: "Configuration de la période de votre campagne",
        nextText: isEncart ? "Création du compte" : "Ancrage local",
        showPrev: true,
        prevText: "Modifier les visuels"
      },
      3: {
        badge: `Étape 3/4 : Configurer l’ancrage local`,
        subtitle: "Région que vous souhaitez cibler",
        nextText: "Création du compte",
        showPrev: true,
        prevText: "Calendrier de diffusion"
      },
      4: {
        badge: this.userSignedInValue 
          ? `Étape ${displayStepNum}/${totalCount} : Informations & Coordonnées`
          : `Étape ${displayStepNum}/${totalCount} : Création du compte`,
        subtitle: this.userSignedInValue
          ? "Vérifiez vos coordonnées professionnelles"
          : "Configuration de votre compte professionnel",
        nextText: "Paiement sécurisé",
        showPrev: true,
        prevText: isEncart ? "Calendrier de diffusion" : "Ancrage local"
      }
    }

    const currentConf = stepConfig[this.currentStep] || stepConfig[1]
    
    if (this.hasStepBadgeTarget) this.stepBadgeTarget.textContent = currentConf.badge
    if (this.hasStepSubtitleTarget) this.stepSubtitleTarget.textContent = currentConf.subtitle
    if (this.hasNextBtnTextTarget) {
      if (this.currentStep === 1 && this.selectedPlan === "monopole") {
        this.nextBtnTextTarget.textContent = "Demander un devis"
      } else {
        this.nextBtnTextTarget.textContent = currentConf.nextText
      }
    }

    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.style.display = currentConf.showPrev ? "inline-flex" : "none"
      if (currentConf.prevText) {
        const textSpan = this.prevBtnTarget.querySelector(".sa-funnel__prev-text")
        if (textSpan) textSpan.textContent = currentConf.prevText
      }
    }

    // 3. Switch Right View Context
    document.querySelectorAll(".sa-funnel__right-view").forEach(view => {
      const viewStep = parseInt(view.dataset.step)
      view.classList.toggle("sa-funnel__right-view--active", viewStep === this.currentStep)
    })

    // Scroll to top smoothly
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  // =========================================================================
  // 2. ÉTAPE 1 : CHOIX DU PLAN, VISUELS, FORMATS & LIVE PREVIEW
  // =========================================================================

  selectPlan(event) {
    const card = event.currentTarget
    const plan = card.dataset.plan
    this.setPlan(plan)
  }

  setPlan(plan) {
    this.selectedPlan = plan

    const cards = (this.hasPlanCardTargets && this.planCardTargets.length > 0) 
      ? this.planCardTargets 
      : document.querySelectorAll(".sa-funnel-plan")

    cards.forEach(card => {
      const cardPlan = card.dataset.plan
      const isCurrent = (cardPlan === plan)
      card.classList.toggle("sa-funnel-plan--active", isCurrent)
      if (isCurrent) {
        card.setAttribute("aria-selected", "true")
      } else {
        card.removeAttribute("aria-selected")
      }
    })

    if (this.hasMonopoleBoxTarget && this.hasStandardFieldsTarget) {
      if (plan === "monopole") {
        this.monopoleBoxTarget.style.display = "flex"
        this.standardFieldsTarget.style.display = "none"
        if (this.hasMonopoleFormTarget) this.monopoleFormTarget.style.display = "flex"
        if (this.hasMonopoleSuccessTarget) this.monopoleSuccessTarget.style.display = "none"
        if (this.hasNextBtnTextTarget && this.currentStep === 1) {
          this.nextBtnTextTarget.textContent = "Demander un devis"
        }
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "inline-flex"
          this.nextBtnTarget.disabled = false
          this.nextBtnTarget.style.opacity = "1"
        }
      } else {
        this.monopoleBoxTarget.style.display = "none"
        this.standardFieldsTarget.style.display = "flex"
        if (this.hasNextBtnTextTarget && this.currentStep === 1) {
          this.nextBtnTextTarget.textContent = "Calendrier de diffusion"
        }
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "inline-flex"
          this.nextBtnTarget.disabled = false
          this.nextBtnTarget.style.opacity = "1"
        }
      }
    }

    this.updateStepView()
    this.updateDatesDisplay()
  }

  async submitMonopoleQuote() {
    const school = this.hasMonopoleSchoolInputTarget ? this.monopoleSchoolInputTarget.value.trim() : ""
    const email = this.hasMonopoleEmailInputTarget ? this.monopoleEmailInputTarget.value.trim() : ""
    const message = this.hasMonopoleMessageInputTarget ? this.monopoleMessageInputTarget.value.trim() : ""

    if (!school) {
      this.setFieldError(this.hasMonopoleSchoolInputTarget ? this.monopoleSchoolInputTarget : null, "Veuillez indiquer le nom de votre établissement.")
      return
    }

    if (!email || !email.includes("@")) {
      this.setFieldError(this.hasMonopoleEmailInputTarget ? this.monopoleEmailInputTarget : null, "Veuillez indiquer une adresse email valide.")
      return
    }

    // Loading state on next button
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.disabled = true
      this.nextBtnTarget.style.opacity = "0.7"
      if (this.hasNextBtnTextTarget) {
        this.nextBtnTextTarget.textContent = "Envoi en cours..."
      }
    }

    try {
      const formData = new FormData()
      formData.append("school_name", school)
      formData.append("email", email)
      formData.append("message", `[Demande de Devis Monopole] ${message}`)

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

      const response = await fetch("/schools-ads/contact", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken || "",
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        // Afficher le message de succès dans la boîte Monopole
        if (this.hasMonopoleFormTarget) this.monopoleFormTarget.style.display = "none"
        if (this.hasMonopoleSuccessTarget) this.monopoleSuccessTarget.style.display = "block"
        
        // Masquer le bouton d'envoi ou changer son texte
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "none"
        }
      } else {
        throw new Error("Erreur réseau")
      }
    } catch (error) {
      console.error("Erreur monopole quote:", error)
      if (this.hasNextBtnTarget) {
        this.nextBtnTarget.disabled = false
        this.nextBtnTarget.style.opacity = "1"
        if (this.hasNextBtnTextTarget) {
          this.nextBtnTextTarget.textContent = "Demander un devis"
        }
      }
      if (this.hasMonopoleSchoolInputTarget) {
        this.setFieldError(this.monopoleSchoolInputTarget, "Une erreur est survenue lors de l'envoi. Veuillez réessayer.")
      }
    }
  }

  selectFormat(event) {
    const pill = event.currentTarget
    const format = pill.dataset.format

    this.formatPillTargets.forEach(p => p.classList.toggle("sa-pill--active", p === pill))
    this.selectedFormat = format

    // Toggle Preview Frames
    if (this.hasPreviewFrameAccueilTarget) this.previewFrameAccueilTarget.style.display = (format === "accueil") ? "block" : "none"
    if (this.hasPreviewFrameRechercheTarget) this.previewFrameRechercheTarget.style.display = (format === "recherche") ? "block" : "none"
    if (this.hasPreviewFrameQuizTarget) this.previewFrameQuizTarget.style.display = (format === "quiz") ? "block" : "none"

    if (this.hasPreviewFormatTagTarget) {
      const formatNames = {
        accueil: "Page d'accueil",
        recherche: "Page recherche",
        quiz: "Page Quiz"
      }
      this.previewFormatTagTarget.textContent = formatNames[format] || "Page d'accueil"
    }

    this.updateDimensionsHint()
  }

  selectDevice(event) {
    const pill = event.currentTarget
    const device = pill.dataset.device

    this.devicePillTargets.forEach(p => p.classList.toggle("sa-pill--active", p === pill))
    this.selectedDevice = device

    const frames = [
      this.hasPreviewFrameAccueilTarget ? this.previewFrameAccueilTarget : null,
      this.hasPreviewFrameRechercheTarget ? this.previewFrameRechercheTarget : null,
      this.hasPreviewFrameQuizTarget ? this.previewFrameQuizTarget : null
    ].filter(Boolean)

    frames.forEach(frame => {
      frame.classList.toggle("sa-preview-frame--mobile", device === "mobile")
      frame.classList.toggle("sa-preview-frame--pc", device === "pc")
    })

    if (this.hasPreviewDeviceLabelTarget) {
      this.previewDeviceLabelTarget.textContent = device === "mobile" ? "Visuel sur Mobile" : "Visuel sur PC"
    }

    if (this.hasUploadContextLabelTarget) {
      this.uploadContextLabelTarget.textContent = device === "mobile" ? "Visuel Mobile" : "Visuel Desktop"
    }

    this.updateDimensionsHint()
    this.updateUploadBoxState()

    // Sync mock previews with corresponding file
    const activeFile = device === "mobile" ? (this.selectedMobileFile || this.selectedFile) : this.selectedFile
    this.renderFileInMockup(activeFile)
  }

  updateUploadBoxState() {
    const activeFile = this.selectedDevice === "mobile" ? this.selectedMobileFile : this.selectedFile

    if (this.hasDesktopStatusDotTarget) {
      this.desktopStatusDotTarget.style.display = this.selectedFile ? "inline-block" : "none"
    }
    if (this.hasMobileStatusDotTarget) {
      this.mobileStatusDotTarget.style.display = this.selectedMobileFile ? "inline-block" : "none"
    }

    if (activeFile) {
      if (this.hasUploadPlaceholderTarget) this.uploadPlaceholderTarget.style.display = "none"
      if (this.hasUploadSuccessTarget) {
        this.uploadSuccessTarget.style.display = "flex"
        if (this.hasUploadFileNameTarget) this.uploadFileNameTarget.textContent = activeFile.name
      }
    } else {
      if (this.hasUploadSuccessTarget) this.uploadSuccessTarget.style.display = "none"
      if (this.hasUploadPlaceholderTarget) this.uploadPlaceholderTarget.style.display = "flex"
    }
  }

  updateLiveText() {
    const title = this.hasTitleInputTarget && this.titleInputTarget.value.trim() 
      ? this.titleInputTarget.value.trim() 
      : "Envie d’afficher un contenu sponsorisé sur Omniscient Design ?"

    const desc = this.hasDescInputTarget && this.descInputTarget.value.trim()
      ? this.descInputTarget.value.trim()
      : "C'est possible, simple et rapide ! Entrez directement en contact avec l'équipe d'Omniscient Design et discutons ensemble de votre projet."

    // 1. Accueil
    if (this.hasPreviewTitleTarget) this.previewTitleTarget.textContent = title
    if (this.hasPreviewDescTarget) this.previewDescTarget.textContent = desc

    // 2. Recherche
    if (this.hasPreviewSearchTitleTarget) this.previewSearchTitleTarget.textContent = title

    // 3. Quiz
    if (this.hasPreviewQuizTitleTarget) this.previewQuizTitleTarget.textContent = title
    if (this.hasPreviewQuizDescTarget) this.previewQuizDescTarget.textContent = desc
  }

  triggerUpload(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    if (this.selectedDevice === "mobile" && this.hasImageMobileInputTarget) {
      this.imageMobileInputTarget.click()
    } else if (this.hasImageInputTarget) {
      this.imageInputTarget.click()
    }
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.selectedFile = file
      if (this.hasDropzoneTarget) {
        this.clearFieldError(this.dropzoneTarget)
      }
      this.updateUploadBoxState()
      this.renderFileInMockup(file)
    }
  }

  handleMobileFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.selectedMobileFile = file
      if (this.hasDropzoneTarget) {
        this.clearFieldError(this.dropzoneTarget)
      }
      this.updateUploadBoxState()
      this.renderFileInMockup(file)
    }
  }

  handleDragOver(event) {
    event.preventDefault()
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.classList.add("sa-upload-box--dragover")
    }
  }

  handleDragLeave(event) {
    event.preventDefault()
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.classList.remove("sa-upload-box--dragover")
    }
  }

  handleDrop(event) {
    event.preventDefault()
    if (this.hasDropzoneTarget) {
      this.dropzoneTarget.classList.remove("sa-upload-box--dragover")
      this.clearFieldError(this.dropzoneTarget)
    }
    if (event.dataTransfer.files && event.dataTransfer.files[0]) {
      const file = event.dataTransfer.files[0]
      if (this.selectedDevice === "mobile") {
        this.selectedMobileFile = file
      } else {
        this.selectedFile = file
      }
      this.updateUploadBoxState()
      this.renderFileInMockup(file)
    }
  }

  updateDimensionsHint() {
    if (!this.hasDimensionLabelTarget) return

    const device = this.selectedDevice || "pc"
    const dimensionsMap = {
      pc: "1920x1080 px (16:9)",
      mobile: "1080x1920 px (9:16)"
    }

    const recommended = dimensionsMap[device] || "1920x1080 px (16:9)"
    this.dimensionLabelTarget.textContent = recommended
  }

  renderFileInMockup(file) {
    if (!file) {
      if (this.hasPreviewEmptyStateTarget) this.previewEmptyStateTarget.style.display = "flex"
      if (this.hasPreviewImageTarget) this.previewImageTarget.style.display = "none"
      if (this.hasPreviewVideoTarget) {
        this.previewVideoTarget.pause()
        this.previewVideoTarget.style.display = "none"
      }
      return
    }

    const isVideo = file.type.startsWith("video/")
    const isImage = file.type.startsWith("image/")

    if (!isImage && !isVideo) {
      if (this.hasDropzoneTarget) {
        this.setFieldError(this.dropzoneTarget, "Format non supporté. Veuillez choisir une image ou vidéo.")
      }
      return
    }

    if (this.hasPreviewEmptyStateTarget) this.previewEmptyStateTarget.style.display = "none"

    const objectUrl = URL.createObjectURL(file)

    if (isVideo) {
      if (this.hasPreviewImageTarget) this.previewImageTarget.style.display = "none"
      if (this.hasPreviewVideoTarget) {
        this.previewVideoTarget.src = objectUrl
        this.previewVideoTarget.style.display = "block"
        this.previewVideoTarget.play().catch(() => {})
      }
    } else {
      if (this.hasPreviewVideoTarget) {
        this.previewVideoTarget.pause()
        this.previewVideoTarget.style.display = "none"
      }
      if (this.hasPreviewImageTarget) {
        this.previewImageTarget.src = objectUrl
        this.previewImageTarget.style.display = "block"
      }
    }
  }



// =========================================================================
// =========================================================================
// 3. ÉTAPE 2 : CALENDRIER & PÉRIODE DE DIFFUSION SUR-MESURE
// =========================================================================

prevMonth() {
  const currentMonthStart = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), 1)
  const todayMonthStart = new Date(this.today.getFullYear(), this.today.getMonth(), 1)
  
  // Ne pas reculer avant le mois en cours
  if (currentMonthStart <= todayMonthStart) return

  this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1)
  this.renderCalendar()
}

nextMonth() {
  this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1)
  this.renderCalendar()
}

handleDayClick(date) {
  const selectedDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  const minDate = this.minStartDate || this.today
  
  // Interdire la sélection d'une date avant J+2
  if (selectedDate < minDate) return

  if (!this.rangeStart || (this.rangeStart && this.rangeEnd)) {
    // 1er clic : Définir le début et réinitialiser la fin
    this.rangeStart = new Date(selectedDate)
    this.rangeEnd = null
  } else if (this.rangeStart && !this.rangeEnd) {
    // 2ème clic : Définir la fin
    if (selectedDate < this.rangeStart) {
      // Si la date cliquée est antérieure, elle devient le nouveau début
      this.rangeStart = new Date(selectedDate)
      this.rangeEnd = null
    } else {
      this.rangeEnd = new Date(selectedDate)
    }
  }
  
  this.renderCalendar()
  this.updateDatesDisplay()
}

renderCalendar() {
  const monthNames = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ]

  const year = this.currentDate.getFullYear()
  const month = this.currentDate.getMonth()

  if (this.hasCalendarMonthYearTarget) {
    this.calendarMonthYearTarget.textContent = `${monthNames[month]} ${year}`
  }

  if (!this.hasCalendarDaysGridTarget) return

  const grid = this.calendarDaysGridTarget
  grid.innerHTML = ""

  const firstDayIndex = (new Date(year, month, 1).getDay() + 6) % 7 // Lundi = 0
  const lastDate = new Date(year, month + 1, 0).getDate()
  const prevLastDate = new Date(year, month, 0).getDate()

  // Jours du mois précédent (inactifs/gris clair / désactivés)
  for (let x = firstDayIndex; x > 0; x--) {
    const dayNum = prevLastDate - x + 1
    const dayEl = document.createElement("button")
    dayEl.type = "button"
    dayEl.className = "sa-cal-day sa-cal-day--prev-month sa-cal-day--disabled"
    dayEl.disabled = true
    dayEl.textContent = dayNum
    grid.appendChild(dayEl)
  }

  // Jours du mois en cours
  for (let i = 1; i <= lastDate; i++) {
    const thisDayDate = new Date(year, month, i)
    const dayEl = document.createElement("button")
    dayEl.type = "button"
    dayEl.className = "sa-cal-day"
    dayEl.textContent = i
    dayEl.dataset.date = thisDayDate.toISOString()

    const isPast = thisDayDate < (this.minStartDate || this.today)

    if (isPast) {
      dayEl.classList.add("sa-cal-day--disabled")
      dayEl.disabled = true
    } else {
      const isStart = this.isSameDay(thisDayDate, this.rangeStart)
      const isEnd = this.isSameDay(thisDayDate, this.rangeEnd)
      const isInRange = this.rangeStart && this.rangeEnd && (thisDayDate > this.rangeStart && thisDayDate < this.rangeEnd)

      if (isStart) {
        dayEl.classList.add("sa-cal-day--start")
      } else if (isEnd) {
        dayEl.classList.add("sa-cal-day--end")
      } else if (isInRange) {
        dayEl.classList.add("sa-cal-day--in-range")
      }

      dayEl.addEventListener("click", () => this.handleDayClick(thisDayDate))
    }

    grid.appendChild(dayEl)
  }

  // Compléter avec les premiers jours du mois suivant
  const totalRendered = firstDayIndex + lastDate
  const nextDaysNeeded = (7 - (totalRendered % 7)) % 7
  for (let n = 1; n <= nextDaysNeeded; n++) {
    const nextDate = new Date(year, month + 1, n)
    const dayEl = document.createElement("button")
    dayEl.type = "button"
    dayEl.className = "sa-cal-day sa-cal-day--next-month"
    dayEl.textContent = n

    const isStart = this.isSameDay(nextDate, this.rangeStart)
    const isEnd = this.isSameDay(nextDate, this.rangeEnd)
    const isInRange = this.rangeStart && this.rangeEnd && (nextDate > this.rangeStart && nextDate < this.rangeEnd)

    if (isStart) dayEl.classList.add("sa-cal-day--start")
    else if (isEnd) dayEl.classList.add("sa-cal-day--end")
    else if (isInRange) dayEl.classList.add("sa-cal-day--in-range")

    dayEl.addEventListener("click", () => this.handleDayClick(nextDate))
    grid.appendChild(dayEl)
  }
}

updateDatesDisplay() {
  const formatDate = (d) => {
    if (!d) return ""
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yyyy = d.getFullYear()
    return `${dd}/${mm}/${yyyy}`
  }

  if (this.hasStartDateInputTarget && this.rangeStart) {
    this.startDateInputTarget.value = formatDate(this.rangeStart)
  }

  if (this.hasEndDateInputTarget) {
    if (this.rangeEnd) {
      this.endDateInputTarget.value = formatDate(this.rangeEnd)
    } else {
      this.endDateInputTarget.value = "Sélectionnez une date de fin..."
    }
  }

  // Calcul du nombre de jours et prorata tarifaire
  if (this.rangeStart) {
    const effectiveEnd = this.rangeEnd || this.rangeStart
    const startMidnight = new Date(this.rangeStart.getFullYear(), this.rangeStart.getMonth(), this.rangeStart.getDate())
    const endMidnight = new Date(effectiveEnd.getFullYear(), effectiveEnd.getMonth(), effectiveEnd.getDate())
    const diffTime = endMidnight.getTime() - startMidnight.getTime()
    const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24)) + 1
    const monthsApprox = (diffDays / 30.0).toFixed(1)

    if (this.hasDurationSummaryTarget) {
      if (diffDays === 30) {
        this.durationSummaryTarget.textContent = "30 jours"
      } else {
        this.durationSummaryTarget.textContent = `${diffDays} jours (~${monthsApprox} mois)`
      }
    }

    if (this.hasPriceSummaryTarget) {
      const monthlyRate = (this.selectedPlan === "encart_natif" || this.selectedPlan === "test_2eur") ? 200 : 400
      if (this.selectedPlan === "test_2eur") {
        this.priceSummaryTarget.textContent = "1,00 €"
      } else {
        const rawPrice = (monthlyRate / 30.0) * diffDays
        const finalPrice = rawPrice.toFixed(2).replace('.', ',')
        this.priceSummaryTarget.textContent = `${finalPrice} €`
      }
    }
  }
}

  isSameDay(d1, d2) {
    if (!d1 || !d2) return false
    return d1.getFullYear() === d2.getFullYear() &&
           d1.getMonth() === d2.getMonth() &&
           d1.getDate() === d2.getDate()
  }

  parseFrenchDate(str) {
    if (!str || typeof str !== "string") return null
    const parts = str.trim().split(/[\/\-.]/)
    if (parts.length === 3) {
      const day = parseInt(parts[0], 10)
      const month = parseInt(parts[1], 10) - 1
      let year = parseInt(parts[2], 10)
      if (year < 100) year += 2000
      if (!isNaN(day) && !isNaN(month) && !isNaN(year) && year > 2020 && month >= 0 && month <= 11 && day >= 1 && day <= 31) {
        const parsed = new Date(year, month, day)
        if (parsed.getFullYear() === year && parsed.getMonth() === month && parsed.getDate() === day) {
          return parsed
        }
      }
    }
    return null
  }

  handleStartDateInputChange(event) {
    const val = event.target.value
    const parsed = this.parseFrenchDate(val)
    if (parsed) {
      const minDate = this.minStartDate || this.today
      if (parsed >= minDate) {
        this.rangeStart = parsed
        // Synchroniser le mois du calendrier sur la date saisie
        this.currentDate = new Date(parsed.getFullYear(), parsed.getMonth(), 1)
        this.renderCalendar()
        this.updateDatesDisplay()
      }
    }
  }

  handleEndDateInputChange(event) {
    const val = event.target.value
    const parsed = this.parseFrenchDate(val)
    if (parsed) {
      if (!this.rangeStart || parsed >= this.rangeStart) {
        this.rangeEnd = parsed
        this.renderCalendar()
        this.updateDatesDisplay()
      }
    }
  }

// =========================================================================
// 4. ÉTAPE 3 : ANCRAGE LOCAL & CARTE INTERACTIVE (MULTI-RÉGIONS)
// =========================================================================

  selectRegion(regionKeyOrEvent) {
    let regionKey = regionKeyOrEvent
    if (typeof regionKeyOrEvent !== "string" && regionKeyOrEvent?.currentTarget) {
      regionKey = regionKeyOrEvent.currentTarget.dataset.regionKey
    }

    if (!regionKey) return
    if (!this.selectedRegionKeys) {
      this.selectedRegionKeys = new Set()
    }

    // Toggle logic : si déjà sélectionnée, on retire (sauf si c'est la seule sélectionnée pour garder au moins 1 région)
    if (this.selectedRegionKeys.has(regionKey)) {
      if (this.selectedRegionKeys.size > 1) {
        this.selectedRegionKeys.delete(regionKey)
      }
    } else {
      this.selectedRegionKeys.add(regionKey)
    }

    this.updateRegionsView()
  }

  updateRegionsView() {
    if (!this.selectedRegionKeys) {
      this.selectedRegionKeys = new Set(["cvl"])
    }

    // 1. Highlight map paths
    let totalEstimatedStudents = 0
    const selectedNames = []

    this.regionPathTargets.forEach(path => {
      const pathKey = path.dataset.regionKey || path.id.replace('funnel-region-', '')
      const isSelected = this.selectedRegionKeys.has(pathKey)
      path.classList.toggle("sa-funnel-map__region--active", isSelected)

      if (isSelected) {
        const count = parseInt(path.dataset.count || "0", 10)
        totalEstimatedStudents += count
        if (path.dataset.region) {
          selectedNames.push(path.dataset.region)
        }
      }
    })

    // 2. Highlight quick chips
    this.regionChipTargets.forEach(chip => {
      const chipKey = chip.dataset.regionKey
      chip.classList.toggle("sa-pill--active", this.selectedRegionKeys.has(chipKey))
    })

    // 3. Update region search input text
    if (this.hasRegionSearchInputTarget) {
      if (selectedNames.length === 0) {
        this.regionSearchInputTarget.value = ""
      } else if (selectedNames.length <= 2) {
        this.regionSearchInputTarget.value = selectedNames.join(", ")
      } else {
        this.regionSearchInputTarget.value = `${selectedNames.length} régions sélectionnées (${selectedNames.slice(0, 2).join(", ")}...)`
      }
    }

    // 4. Update student count estimation box
    if (this.hasStudentCountTarget) {
      this.studentCountTarget.textContent = `${totalEstimatedStudents.toLocaleString("fr-FR")} étudiants`
    }
  }

  filterRegions(event) {
    const query = event.target.value.toLowerCase().trim()
    if (!query) return

    const regionAliases = {
      idf: ["ile de france", "paris", "idf", "île-de-france"],
      bre: ["bretagne", "finistere", "rennes", "quimper"],
      naq: ["nouvelle aquitaine", "bordeaux", "naq", "nouvelle-aquitaine"],
      cvl: ["centre", "centre-val de loire", "cvl", "orleans", "tours"],
      ara: ["auvergne", "rhone", "alpes", "lyon", "ara"],
      pac: ["paca", "provence", "marseille", "nice", "côte d'azur"],
      hdf: ["hauts de france", "lille", "hdf"],
      occ: ["occitanie", "toulouse", "montpellier"],
      ges: ["grand est", "alsace", "lorraine", "strasbourg"],
      pdl: ["pays de la loire", "nantes", "angers"],
      nor: ["normandie", "rouen", "caen"],
      bfc: ["bourgogne", "franche comte", "franche-comte", "dijon"],
      cor: ["corse", "ajaccio", "bastia"]
    }

    for (const [key, aliases] of Object.entries(regionAliases)) {
      if (aliases.some(a => a.includes(query) || query.includes(a))) {
        if (!this.selectedRegionKeys.has(key)) {
          this.selectedRegionKeys.add(key)
          this.updateRegionsView()
        }
        break
      }
    }
  }

  // --- INTERACTIVE FRANCE MAP TOOLTIP ---
  showRegionTooltip(event) {
    const regionEl = event.currentTarget
    const regionName = regionEl.dataset.region
    const count = regionEl.dataset.count
    const percent = regionEl.dataset.percent

    if (this.hasMapTooltipTarget) {
      if (this.hasTooltipRegionTarget) this.tooltipRegionTarget.textContent = regionName || ""
      if (this.hasTooltipCountTarget) this.tooltipCountTarget.textContent = `${count || 0} étudiants`
      if (this.hasTooltipPercentTarget) this.tooltipPercentTarget.textContent = `${percent || "0%"} de l'audience`

      this.mapTooltipTarget.classList.add("sa-map-tooltip--visible")
      this.positionTooltip(event)
    }
  }

  moveRegionTooltip(event) {
    if (this.hasMapTooltipTarget) {
      this.positionTooltip(event)
    }
  }

  hideRegionTooltip() {
    if (this.hasMapTooltipTarget) {
      this.mapTooltipTarget.classList.remove("sa-map-tooltip--visible")
    }
  }

  positionTooltip(event) {
    const tooltip = this.mapTooltipTarget
    const wrapper = tooltip.closest(".sa-funnel__map-area") || tooltip.parentElement
    if (!wrapper) return

    const rect = wrapper.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top

    tooltip.style.left = `${x}px`
    tooltip.style.top = `${y}px`
  }

  // =========================================================================
  // 5. ÉTAPE 4 : MOT DE PASSE & SOUMISSION CHECKOUT STRIPE
  // =========================================================================

  togglePassword(event) {
    const inputId = event.currentTarget.dataset.targetInput
    const input = document.getElementById(inputId)
    if (input) {
      input.type = input.type === "password" ? "text" : "password"
    }
  }

  async submitCheckout() {
    const nextBtn = this.nextBtnTarget
    const originalText = nextBtn.innerHTML
    nextBtn.disabled = true
    nextBtn.innerHTML = "<span>Traitement du paiement...</span>"

    try {
      const formData = new FormData()
      
      formData.append("title", this.hasTitleInputTarget ? this.titleInputTarget.value : "")
      formData.append("description", this.hasDescInputTarget ? this.descInputTarget.value : "")
      formData.append("link", this.hasLinkInputTarget ? this.linkInputTarget.value : "")
      formData.append("format_type", "all")
      formData.append("plan_type", this.selectedPlan || "ancrage_local")
      
      if (this.rangeStart) {
        formData.append("start_date", this.rangeStart.toISOString().split('T')[0])
      }
      if (this.rangeEnd) {
        formData.append("end_date", this.rangeEnd.toISOString().split('T')[0])
      }

      // Récupérer tous les noms de régions sélectionnés (uniquement si plan ancrage local)
      if (this.selectedPlan === "ancrage_local") {
        const selectedRegionNames = []
        this.regionPathTargets.forEach(path => {
          const pathKey = path.dataset.regionKey || path.id.replace('funnel-region-', '')
          if (this.selectedRegionKeys && this.selectedRegionKeys.has(pathKey) && path.dataset.region) {
            selectedRegionNames.push(path.dataset.region)
          }
        })
        const regionsString = selectedRegionNames.length > 0 
          ? selectedRegionNames.join(", ") 
          : (this.hasRegionSearchInputTarget ? this.regionSearchInputTarget.value : "Centre-Val de Loire")

        formData.append("region", regionsString)
      } else {
        formData.append("region", "Nationale")
      }
      formData.append("school_name", this.hasSchoolNameInputTarget ? this.schoolNameInputTarget.value : "")
      formData.append("domain", this.hasDomainInputTarget ? this.domainInputTarget.value : "")
      formData.append("email", this.hasEmailInputTarget ? this.emailInputTarget.value : "")
      
      if (this.hasPasswordInputTarget && this.passwordInputTarget.value) {
        formData.append("password", this.passwordInputTarget.value)
        formData.append("password_confirmation", this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget.value : "")
      }

      if (this.selectedFile) {
        formData.append("image", this.selectedFile)
      }
      if (this.selectedMobileFile) {
        formData.append("image_mobile", this.selectedMobileFile)
      }

      // CSRF token
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

      const checkoutEndpoint = this.hasCheckoutUrlValue 
        ? this.checkoutUrlValue 
        : "/schools-ads/checkout"

      const response = await fetch(checkoutEndpoint, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken || "",
          "Accept": "application/json"
        },
        body: formData
      })

      let result
      try {
        result = await response.json()
      } catch (jsonErr) {
        console.error("Non-JSON response from server:", jsonErr)
        result = { success: false, message: "Le serveur a retourné une réponse inattendue. Veuillez réessayer." }
      }

      if (result.success && result.checkout_url) {
        window.location.href = result.checkout_url
      } else {
        const errorField = result.field
        let targetEl = this.hasEmailInputTarget ? this.emailInputTarget : null

        if (errorField === 'password' && this.hasPasswordInputTarget) {
          targetEl = this.passwordInputTarget
        } else if (errorField === 'password_confirmation' && this.hasPasswordConfirmInputTarget) {
          targetEl = this.passwordConfirmInputTarget
        } else if (errorField === 'school_name' && this.hasSchoolNameInputTarget) {
          targetEl = this.schoolNameInputTarget
        }

        if (targetEl) {
          this.setFieldError(targetEl, result.message || "Une erreur est survenue lors de l'initialisation.")
        } else if (this.hasEmailInputTarget) {
          this.setFieldError(this.emailInputTarget, result.message || "Une erreur est survenue lors de l'initialisation.")
        }
        nextBtn.disabled = false
        nextBtn.innerHTML = originalText
      }
    } catch (error) {
      console.error("Erreur checkout:", error)
      if (this.hasEmailInputTarget) {
        this.setFieldError(this.emailInputTarget, "Erreur de connexion au serveur de paiement. Veuillez réessayer.")
      }
      nextBtn.disabled = false
      nextBtn.innerHTML = originalText
    }
  }

  formatLinkInput() {
    if (!this.hasLinkInputTarget) return
    let val = this.linkInputTarget.value.trim()
    if (!val) return

    if (!val.startsWith("http://") && !val.startsWith("https://")) {
      this.linkInputTarget.value = `https://${val}`
    }
  }
}
