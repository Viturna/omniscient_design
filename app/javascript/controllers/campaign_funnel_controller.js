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
    
    // Step 2 : Calendrier
    "startDateInput",
    "endDateInput",
    "calendarMonthYear",
    "calendarDaysGrid",
    "durationSummary",
    
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
    "passwordConfirmInput"
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
    
    // Calendar state (Forcément par mois complet)
    this.currentDate = new Date(2026, 8, 1) // Septembre 2026
    this.rangeStart = new Date(2026, 8, 1)  // 1er Septembre 2026
    this.rangeEnd = new Date(2026, 8, 30)   // 30 Septembre 2026 (Fin de mois)
    this.monthSelectionInProgress = false

    // Check URL parameters (e.g. ?plan=encart_natif or ?plan=monopole)
    const urlParams = new URLSearchParams(window.location.search)
    const paramPlan = urlParams.get('plan')
    if (paramPlan && ['encart_natif', 'ancrage_local', 'monopole'].includes(paramPlan)) {
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
      const link = this.hasLinkInputTarget ? this.linkInputTarget.value.trim() : ""

      if (!link) {
        this.setFieldError(this.hasLinkInputTarget ? this.linkInputTarget : null, "Veuillez renseigner un lien de redirection.")
        isValid = false
      }

      if (!desc) {
        this.setFieldError(this.hasDescInputTarget ? this.descInputTarget : null, "Veuillez renseigner une description pour votre campagne.")
        isValid = false
      }

      if (!title) {
        this.setFieldError(this.hasTitleInputTarget ? this.titleInputTarget : null, "Veuillez renseigner un titre pour votre campagne.")
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

      if (password && password !== confirmPassword) {
        this.setFieldError(this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget : null, "Les mots de passe ne correspondent pas.")
        isValid = false
      }

      if (password && password.length < 6) {
        this.setFieldError(this.hasPasswordInputTarget ? this.passwordInputTarget : null, "Le mot de passe doit contenir au moins 6 caractères.")
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
        this.setFieldError(this.hasSchoolNameInputTarget ? this.schoolNameInputTarget : null, "Veuillez renseigner le nom de votre entreprise.")
        isValid = false
      }

      return isValid
    }

    return true
  }

  setFieldError(inputEl, message) {
    if (!inputEl) return
    inputEl.classList.add("sa-funnel__input--error")

    const fieldContainer = inputEl.closest(".sa-funnel__field") || inputEl.parentElement
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
    }
    inputEl.addEventListener("input", clearHandler)
    inputEl.addEventListener("change", clearHandler)
  }

  clearFieldError(inputEl) {
    if (!inputEl) return
    inputEl.classList.remove("sa-funnel__input--error", "sa-funnel__textarea--error", "sa-funnel__select--error")
    const fieldContainer = inputEl.closest(".sa-funnel__field") || inputEl.parentElement
    if (fieldContainer) {
      const existingError = fieldContainer.querySelector(".sa-funnel__field-error")
      if (existingError) existingError.remove()
    }
  }

  clearAllErrors() {
    this.element.querySelectorAll(".sa-funnel__input--error, .sa-funnel__textarea--error, .sa-funnel__select--error").forEach(el => {
      el.classList.remove("sa-funnel__input--error", "sa-funnel__textarea--error", "sa-funnel__select--error")
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
        nextText: "Calendrier de diffusion →",
        showPrev: false
      },
      2: {
        badge: `Étape 2/${totalCount} : Calendrier de diffusion`,
        subtitle: "Configuration de la période de votre campagne",
        nextText: isEncart ? "Création du compte →" : "Ancrage local →",
        showPrev: true,
        prevText: "← Modifier les visuels"
      },
      3: {
        badge: `Étape 3/4 : Configurer l’ancrage local`,
        subtitle: "Région que vous souhaitez cibler",
        nextText: "Création du compte →",
        showPrev: true,
        prevText: "← Calendrier de diffusion"
      },
      4: {
        badge: `Étape ${displayStepNum}/${totalCount} : Création du compte`,
        subtitle: "Configuration de votre compte professionnel",
        nextText: "Paiement sécurisé →",
        showPrev: true,
        prevText: isEncart ? "← Calendrier de diffusion" : "← Ancrage local"
      }
    }

    const currentConf = stepConfig[this.currentStep] || stepConfig[1]
    
    if (this.hasStepBadgeTarget) this.stepBadgeTarget.textContent = currentConf.badge
    if (this.hasStepSubtitleTarget) this.stepSubtitleTarget.textContent = currentConf.subtitle
    if (this.hasNextBtnTextTarget) {
      if (this.currentStep === 1 && this.selectedPlan === "monopole") {
        this.nextBtnTextTarget.textContent = "Demander un devis →"
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
        if (this.hasNextBtnTextTarget && this.currentStep === 1) {
          this.nextBtnTextTarget.textContent = "Demander un devis →"
        }
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "inline-flex"
        }
      } else {
        this.monopoleBoxTarget.style.display = "none"
        this.standardFieldsTarget.style.display = "flex"
        if (this.hasNextBtnTextTarget && this.currentStep === 1) {
          this.nextBtnTextTarget.textContent = "Calendrier de diffusion →"
        }
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "inline-flex"
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
      this.markInputError(this.hasMonopoleSchoolInputTarget ? this.monopoleSchoolInputTarget : null, "Veuillez indiquer le nom de votre établissement.")
      return
    }

    if (!email || !email.includes("@")) {
      this.markInputError(this.hasMonopoleEmailInputTarget ? this.monopoleEmailInputTarget : null, "Veuillez indiquer une adresse email valide.")
      return
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

      setTimeout(() => {
        window.location.href = "/schools-ads"
      }, 1000)
    } catch (error) {
      console.error("Erreur monopole quote:", error)
      if (this.hasMonopoleSchoolInputTarget) {
        this.setFieldError(this.monopoleSchoolInputTarget, "Une erreur est survenue. Veuillez réessayer.")
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

    this.updateDimensionsHint()

    // Update active media preview based on device if mobile file was uploaded
    if (device === "mobile" && this.selectedMobileFile) {
      this.displayFileInPreview(this.selectedMobileFile)
    } else if (device === "pc" && this.selectedFile) {
      this.displayFileInPreview(this.selectedFile)
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
      this.displayFileInPreview(file)
    }
  }

  handleMobileFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.selectedMobileFile = file
      this.displayFileInPreview(file)
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
    }
    if (event.dataTransfer.files && event.dataTransfer.files[0]) {
      const file = event.dataTransfer.files[0]
      if (this.selectedDevice === "mobile") {
        this.selectedMobileFile = file
      } else {
        this.selectedFile = file
      }
      this.displayFileInPreview(file)
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

  displayFileInPreview(file) {
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

    if (this.hasUploadPlaceholderTarget) this.uploadPlaceholderTarget.style.display = "none"
    if (this.hasUploadSuccessTarget) {
      this.uploadSuccessTarget.style.display = "flex"
      if (this.hasUploadFileNameTarget) this.uploadFileNameTarget.textContent = file.name
    }
  }

  // =========================================================================
  // 3. ÉTAPE 2 : CALENDRIER INTERACTIF & SÉLECTION DE DATES
  // =========================================================================

  prevMonth() {
    this.currentDate.setMonth(this.currentDate.getMonth() - 1)
    this.renderCalendar()
  }

  nextMonth() {
    this.currentDate.setMonth(this.currentDate.getMonth() + 1)
    this.renderCalendar()
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
      const dayEl = document.createElement("div")
      dayEl.className = "sa-cal-day sa-cal-day--disabled"
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

      // Highlight logic
      if (this.rangeStart && this.rangeEnd) {
        const isStart = this.isSameDay(thisDayDate, this.rangeStart)
        const isEnd = this.isSameDay(thisDayDate, this.rangeEnd)
        const isInRange = thisDayDate >= this.rangeStart && thisDayDate <= this.rangeEnd

        if (isStart) {
          dayEl.classList.add("sa-cal-day--start")
        } else if (isInRange) {
          dayEl.classList.add("sa-cal-day--selected")
        }
      } else if (this.rangeStart && this.isSameDay(thisDayDate, this.rangeStart)) {
        dayEl.classList.add("sa-cal-day--start")
      }

      dayEl.addEventListener("click", () => this.handleDayClick(thisDayDate))
      grid.appendChild(dayEl)
    }
  }

  handleDayClick(date) {
    const clickedMonthStart = new Date(date.getFullYear(), date.getMonth(), 1)
    const clickedMonthEnd = new Date(date.getFullYear(), date.getMonth() + 1, 0)

    if (!this.monthSelectionInProgress) {
      // 1er clic : sélectionne le mois entier correspondant au jour cliqué
      this.rangeStart = clickedMonthStart
      this.rangeEnd = clickedMonthEnd
      this.monthSelectionInProgress = true
      this.selectionAnchor = { year: date.getFullYear(), month: date.getMonth() }
    } else {
      // 2e clic : étend la période du 1er jour du mois de début au dernier jour du mois de fin
      const y1 = this.selectionAnchor.year
      const m1 = this.selectionAnchor.month
      const y2 = date.getFullYear()
      const m2 = date.getMonth()

      let startYear, startMonth, endYear, endMonth
      if (y1 < y2 || (y1 === y2 && m1 <= m2)) {
        startYear = y1; startMonth = m1; endYear = y2; endMonth = m2
      } else {
        startYear = y2; startMonth = m2; endYear = y1; endMonth = m1
      }

      this.rangeStart = new Date(startYear, startMonth, 1)
      this.rangeEnd = new Date(endYear, endMonth + 1, 0)
      this.monthSelectionInProgress = false
    }

    this.renderCalendar()
    this.updateDatesDisplay()
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

    if (this.hasDurationSummaryTarget && this.rangeStart && this.rangeEnd) {
      const monthsCount = Math.max(1, (this.rangeEnd.getFullYear() - this.rangeStart.getFullYear()) * 12 + (this.rangeEnd.getMonth() - this.rangeStart.getMonth()) + 1)
      const diffDays = Math.round((this.rangeEnd - this.rangeStart) / (1000 * 60 * 60 * 24)) + 1
      const monthLabel = monthsCount === 1 ? "1 mois complet" : `${monthsCount} mois complets`
      this.durationSummaryTarget.textContent = `${monthLabel} de diffusion (${diffDays} jours)`
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

    // 3. Update region info & student estimation
    const regionNames = {
      cvl: "Centre-Val de Loire",
      idf: "Île-de-France",
      bre: "Bretagne",
      naq: "Nouvelle-Aquitaine",
      ara: "Auvergne-Rhône-Alpes",
      pac: "PACA",
      hdf: "Hauts-de-France",
      nor: "Normandie",
      ges: "Grand Est",
      pdl: "Pays de la Loire",
      bfc: "Bourgogne-Franche-Comté",
      occ: "Occitanie",
      cor: "Corse"
    }

    const studentEstimations = {
      cvl: "120 étudiants",
      idf: "480 étudiants",
      bre: "190 étudiants",
      naq: "240 étudiants",
      ara: "310 étudiants",
      pac: "210 étudiants",
      hdf: "220 étudiants",
      nor: "130 étudiants",
      ges: "180 étudiants",
      pdl: "195 étudiants",
      bfc: "110 étudiants",
      occ: "260 étudiants",
      cor: "45 étudiants"
    }

    if (this.hasRegionSearchInputTarget && regionNames[regionKey]) {
      this.regionSearchInputTarget.value = regionNames[regionKey]
    }

    if (this.hasStudentCountTarget && studentEstimations[regionKey]) {
      this.studentCountTarget.textContent = studentEstimations[regionKey]
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

      const result = await response.json()

      if (result.success && result.checkout_url) {
        window.location.href = result.checkout_url
      } else {
        if (this.hasEmailInputTarget) {
          this.setFieldError(this.emailInputTarget, result.message || "Une erreur est survenue lors de l'initialisation du paiement.")
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
}
