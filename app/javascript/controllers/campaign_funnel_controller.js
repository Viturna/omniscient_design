import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    checkoutUrl: String
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
    "cgvCheckbox"
  ]

connect() {
  this.currentStep = 1
  this.totalSteps = 4
  
  // Form data state
  this.selectedPlan = "ancrage_local"
  this.selectedFormat = "accueil"
  this.selectedDevice = "pc"
  this.selectedRegionKey = "cvl" // Centre-Val de Loire par défaut comme sur la maquette
  this.selectedFile = null
  this.selectedMobileFile = null
  
  // Calendar state (Exactement 1 mois à partir du 1er Septembre 2026 par défaut)
  this.currentDate = new Date(2026, 8, 1) // Septembre 2026
  this.rangeStart = new Date(2026, 8, 1)  // 1er Septembre 2026
  this.rangeEnd = new Date(2026, 9, 1)    // 1er Octobre 2026 (1 mois)
  this.monthSelectionInProgress = false

  // Check URL parameters (e.g. ?plan=encart_natif or ?plan=monopole)
  const urlParams = new URLSearchParams(window.location.search)
  const paramPlan = urlParams.get("plan")
  if (paramPlan && ["encart_natif", "ancrage_local", "monopole"].includes(paramPlan)) {
    this.selectedPlan = paramPlan
  }
  
  // Initial renders
  this.setPlan(this.selectedPlan)
  this.updateStepView()
  this.renderCalendar()
  this.updateDatesDisplay()
  this.selectRegion("cvl")
}

  // =========================================================================
  // 1. GESTION DES ÉTAPES (NAVIGATION & VALIDATION)
  // =========================================================================

  get isEncartNatif() {
    return this.selectedPlan === "encart_natif"
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
          this.setFieldError(this.startDateInputTarget, "Veuillez sélectionner votre période sur le calendrier.")
        }
        return false
      }
    } else if (this.currentStep === 4) {
      let isValid = true
      const schoolName = this.hasSchoolNameInputTarget ? this.schoolNameInputTarget.value.trim() : ""
      const domain = this.hasDomainInputTarget ? this.domainInputTarget.value : ""
      const email = this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : ""
      const password = this.hasPasswordInputTarget ? this.passwordInputTarget.value : ""
      const confirmPassword = this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget.value : ""

      // Si un mot de passe est saisi OU si le mot de passe est requis
      if (password) {
        if (password !== confirmPassword) {
          this.setFieldError(this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget : null, "Les mots de passe ne correspondent pas.")
          isValid = false
        } else {
          // Validation stricte Omniscient (min 6 car., 1 maj, 1 min, 1 chiffre, 1 car. spécial)
          const pwdRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_]).{6,}$/
          if (!pwdRegex.test(password)) {
            this.setFieldError(this.passwordInputTarget, "Le mot de passe doit comporter au moins 6 caractères, 1 majuscule, 1 minuscule, 1 chiffre et 1 caractère spécial.")
            isValid = false
          }
        }
      } else if (this.hasPasswordInputTarget && this.passwordInputTarget.hasAttribute("required")) {
        this.setFieldError(this.passwordInputTarget, "Veuillez renseigner un mot de passe.")
        isValid = false
      }

      if (!email || !email.includes("@")) {
        this.setFieldError(this.hasEmailInputTarget ? this.emailInputTarget : null, "Veuillez renseigner une adresse email valide.")
        isValid = false
      }

      if (!domain) {
        this.setFieldError(this.hasDomainInputTarget ? this.domainInputTarget : null, "Veuillez choisir un domaine d'activité.")
        isValid = false
      }

      if (!schoolName) {
        this.setFieldError(this.hasSchoolNameInputTarget ? this.schoolNameInputTarget : null, "Veuillez renseigner le nom de votre établissement ou entreprise.")
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
        badge: `Étape ${displayStepNum}/${totalCount} : Création du compte`,
        subtitle: "Configuration de votre compte professionnel",
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
    if (activeFile) {
      this.renderFileInMockup(activeFile)
    }
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

    const format = this.selectedFormat || "accueil"
    const device = this.selectedDevice || "pc"

    const dimensionsMap = {
      accueil: {
        pc: "1920x1080 px (16:9)",
        mobile: "1080x1920 px (9:16)"
      },
      recherche: {
        pc: "800x600 px (4:3)",
        mobile: "600x800 px (3:4)"
      },
      quiz: {
        pc: "1200x800 px (3:2)",
        mobile: "800x800 px (Carré 1:1)"
      }
    }

    const recommended = dimensionsMap[format]?.[device] || "1920x1080 px"
    this.dimensionLabelTarget.textContent = recommended
  }

  renderFileInMockup(file) {
    const isVideo = file.type.startsWith("video/")
    const isImage = file.type.startsWith("image/")

    if (!isImage && !isVideo) {
      if (this.hasDropzoneTarget) {
        this.setFieldError(this.dropzoneTarget, "Format non supporté. Veuillez choisir une image ou vidéo.")
      }
      return
    }

    const objectUrl = URL.createObjectURL(file)

    // Set preview images/videos across all 3 formats
    const imgTargets = [
      this.hasPreviewImageTarget ? this.previewImageTarget : null,
      this.hasPreviewImageBgTarget ? this.previewImageBgTarget : null,
      this.hasPreviewSearchImageTarget ? this.previewSearchImageTarget : null,
      this.hasPreviewQuizImageTarget ? this.previewQuizImageTarget : null
    ].filter(Boolean)

    const videoTargets = [
      this.hasPreviewVideoTarget ? this.previewVideoTarget : null,
      this.hasPreviewVideoBgTarget ? this.previewVideoBgTarget : null,
      this.hasPreviewSearchVideoTarget ? this.previewSearchVideoTarget : null,
      this.hasPreviewQuizVideoTarget ? this.previewQuizVideoTarget : null
    ].filter(Boolean)

    if (isVideo) {
      imgTargets.forEach(img => img.style.display = "none")
      videoTargets.forEach(video => {
        video.src = objectUrl
        video.style.display = "block"
        video.play().catch(() => {})
      })
    } else {
      videoTargets.forEach(video => {
        video.pause()
        video.style.display = "none"
      })
      imgTargets.forEach(img => {
        img.src = objectUrl
        img.style.display = "block"
      })
    }
  }



// =========================================================================
// 3. ÉTAPE 2 : CALENDRIER & PÉRIODE DE 1 MOIS
// =========================================================================

prevMonth() {
  this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1)
  this.renderCalendar()
}

nextMonth() {
  this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1)
  this.renderCalendar()
}

handleDayClick(date) {
  this.rangeStart = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  // 1 mois exact : même jour le mois suivant
  this.rangeEnd = new Date(date.getFullYear(), date.getMonth() + 1, date.getDate())
  
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

  // Jours du mois précédent (inactifs/gris clair)
  for (let x = firstDayIndex; x > 0; x--) {
    const dayNum = prevLastDate - x + 1
    const prevDate = new Date(year, month - 1, dayNum)
    const dayEl = document.createElement("button")
    dayEl.type = "button"
    dayEl.className = "sa-cal-day sa-cal-day--prev-month"
    dayEl.textContent = dayNum
    
    const isInRange = this.rangeStart && this.rangeEnd && (prevDate >= this.rangeStart && prevDate <= this.rangeEnd)
    const isStart = this.isSameDay(prevDate, this.rangeStart)
    const isEnd = this.isSameDay(prevDate, this.rangeEnd)

    if (isStart) dayEl.classList.add("sa-cal-day--start")
    else if (isEnd) dayEl.classList.add("sa-cal-day--end")
    else if (isInRange) dayEl.classList.add("sa-cal-day--in-range")

    dayEl.addEventListener("click", () => this.handleDayClick(prevDate))
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

    const isInRange = this.rangeStart && this.rangeEnd && (thisDayDate >= this.rangeStart && thisDayDate <= this.rangeEnd)
    const isStart = this.isSameDay(thisDayDate, this.rangeStart)
    const isEnd = this.isSameDay(thisDayDate, this.rangeEnd)

    if (isStart) {
      dayEl.classList.add("sa-cal-day--start")
    } else if (isEnd) {
      dayEl.classList.add("sa-cal-day--end")
    } else if (isInRange) {
      dayEl.classList.add("sa-cal-day--in-range")
    }

    dayEl.addEventListener("click", () => this.handleDayClick(thisDayDate))
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

    const isInRange = this.rangeStart && this.rangeEnd && (nextDate >= this.rangeStart && nextDate <= this.rangeEnd)
    const isStart = this.isSameDay(nextDate, this.rangeStart)
    const isEnd = this.isSameDay(nextDate, this.rangeEnd)

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

  if (this.hasEndDateInputTarget && this.rangeEnd) {
    this.endDateInputTarget.value = formatDate(this.rangeEnd)
  }
}

isSameDay(d1, d2) {
  if (!d1 || !d2) return false
  return d1.getFullYear() === d2.getFullYear() &&
         d1.getMonth() === d2.getMonth() &&
         d1.getDate() === d2.getDate()
}

// =========================================================================
// 4. ÉTAPE 3 : ANCRAGE LOCAL & CARTE INTERACTIVE

  // =========================================================================

  selectRegion(regionKeyOrEvent) {
    let regionKey = regionKeyOrEvent
    if (typeof regionKeyOrEvent !== "string" && regionKeyOrEvent?.currentTarget) {
      regionKey = regionKeyOrEvent.currentTarget.dataset.regionKey
    }

    if (!regionKey) return
    this.selectedRegionKey = regionKey

    // 1. Highlight map path
    this.regionPathTargets.forEach(path => {
      const isSelected = path.id === `funnel-region-${regionKey}`
      path.classList.toggle("sa-funnel-map__region--active", isSelected)
    })

    // 2. Highlight quick chip
    this.regionChipTargets.forEach(chip => {
      chip.classList.toggle("sa-pill--active", chip.dataset.regionKey === regionKey)
    })

    // 3. Update region info & student estimation dynamically from map data
    const matchedPath = this.regionPathTargets.find(path => path.id === `funnel-region-${regionKey}`)
    const dynamicRegionName = matchedPath?.dataset.region || regionKey
    const dynamicCount = matchedPath?.dataset.count

    if (this.hasRegionSearchInputTarget) {
      this.regionSearchInputTarget.value = dynamicRegionName
    }

    if (this.hasStudentCountTarget && dynamicCount) {
      this.studentCountTarget.textContent = `${dynamicCount} étudiants`
    }
  }

  filterRegions(event) {
    const query = event.target.value.toLowerCase().trim()
    const regionAliases = {
      idf: ["ile de france", "paris", "idf", "île-de-france"],
      bre: ["bretagne", "finistere", "rennes", "quimper"],
      naq: ["nouvelle aquitaine", "bordeaux", "naq", "nouvelle-aquitaine"],
      cvl: ["centre", "centre-val de loire", "cvl", "orleans", "tours"],
      ara: ["auvergne", "rhone", "alpes", "lyon", "ara"],
      pac: ["paca", "provence", "marseille", "nice", "côte d'azur"],
      hdf: ["hauts de france", "lille", "hdf"],
      occ: ["occitanie", "toulouse", "montpellier"]
    }

    for (const [key, aliases] of Object.entries(regionAliases)) {
      if (aliases.some(a => a.includes(query) || query.includes(a))) {
        this.selectRegion(key)
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

      formData.append("region", this.hasRegionSearchInputTarget ? this.regionSearchInputTarget.value : "Centre-Val de Loire")
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
