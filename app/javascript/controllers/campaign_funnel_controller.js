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
    "previewImage",
    "previewVideo",
    "previewTitle",
    "previewDesc",
    "previewDeviceLabel",
    
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
    
    // Calendar state
    this.currentDate = new Date(2026, 8, 1) // Septembre 2026
    this.rangeStart = new Date(2026, 8, 7) // 7 Septembre
    this.rangeEnd = new Date(2026, 8, 31) // 31 Septembre

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

  nextStep() {
    if (!this.validateCurrentStep()) {
      return
    }

    if (this.currentStep < this.totalSteps) {
      this.currentStep++
      this.updateStepView()
    } else {
      this.submitCheckout()
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--
      this.updateStepView()
    }
  }

  validateCurrentStep() {
    if (this.currentStep === 1) {
      const title = this.hasTitleInputTarget ? this.titleInputTarget.value.trim() : ""
      const link = this.hasLinkInputTarget ? this.linkInputTarget.value.trim() : ""

      if (!title) {
        alert("Veuillez renseigner un titre pour votre campagne.")
        if (this.hasTitleInputTarget) this.titleInputTarget.focus()
        return false
      }
      if (!link) {
        alert("Veuillez renseigner un lien de redirection.")
        if (this.hasLinkInputTarget) this.linkInputTarget.focus()
        return false
      }
    } else if (this.currentStep === 2) {
      if (!this.rangeStart || !this.rangeEnd) {
        alert("Veuillez sélectionner votre période de diffusion sur le calendrier.")
        return false
      }
    } else if (this.currentStep === 4) {
      const schoolName = this.hasSchoolNameInputTarget ? this.schoolNameInputTarget.value.trim() : ""
      const email = this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : ""
      const password = this.hasPasswordInputTarget ? this.passwordInputTarget.value : ""
      const confirmPassword = this.hasPasswordConfirmInputTarget ? this.passwordConfirmInputTarget.value : ""

      if (!schoolName) {
        alert("Veuillez renseigner le nom de votre entreprise ou école.")
        if (this.hasSchoolNameInputTarget) this.schoolNameInputTarget.focus()
        return false
      }
      if (!email || !email.includes("@")) {
        alert("Veuillez renseigner une adresse email valide.")
        if (this.hasEmailInputTarget) this.emailInputTarget.focus()
        return false
      }
      if (password && password.length < 6) {
        alert("Le mot de passe doit contenir au moins 6 caractères.")
        if (this.hasPasswordInputTarget) this.passwordInputTarget.focus()
        return false
      }
      if (password && password !== confirmPassword) {
        alert("Les mots de passe ne correspondent pas.")
        if (this.hasPasswordConfirmInputTarget) this.passwordConfirmInputTarget.focus()
        return false
      }
    }

    return true
  }

  updateStepView() {
    // 1. Switch left form panels
    this.stepPanelTargets.forEach(panel => {
      const panelStep = parseInt(panel.dataset.step)
      panel.classList.toggle("sa-funnel__panel--active", panelStep === this.currentStep)
    })

    // 2. Update Header Titles & CTA Text
    const stepConfig = {
      1: {
        badge: "Étape 1/4 : Visuels",
        subtitle: "Configuration des visuels de votre campagne",
        nextText: "Calendrier de diffusion →",
        showPrev: false
      },
      2: {
        badge: "Étape 2/4 : Calendrier de diffusion",
        subtitle: "Configuration de la période de votre campagne",
        nextText: "Encrage local →",
        showPrev: true,
        prevText: "← Modifier les visuels"
      },
      3: {
        badge: "Étape 3/4 : Configurer l’encrage local",
        subtitle: "Région que vous souhaitez cibler",
        nextText: "Création du compte →",
        showPrev: true,
        prevText: "← Calendrier de diffusion"
      },
      4: {
        badge: "Étape 4/4 : Création du compte",
        subtitle: "Configuration de votre compte professionnel",
        nextText: "Paiement sécurisé →",
        showPrev: true,
        prevText: "← Encrage local"
      }
    }

    const currentConf = stepConfig[this.currentStep] || stepConfig[1]
    
    if (this.hasStepBadgeTarget) this.stepBadgeTarget.textContent = currentConf.badge
    if (this.hasStepSubtitleTarget) this.stepSubtitleTarget.textContent = currentConf.subtitle
    if (this.hasNextBtnTextTarget) this.nextBtnTextTarget.textContent = currentConf.nextText

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

    if (this.hasPlanCardTargets) {
      this.planCardTargets.forEach(card => {
        const cardPlan = card.dataset.plan
        card.classList.toggle("sa-funnel-plan--active", cardPlan === plan)
      })
    }

    if (this.hasMonopoleBoxTarget && this.hasStandardFieldsTarget) {
      if (plan === "monopole") {
        this.monopoleBoxTarget.style.display = "block"
        this.standardFieldsTarget.style.display = "none"
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "none"
        }
      } else {
        this.monopoleBoxTarget.style.display = "none"
        this.standardFieldsTarget.style.display = "block"
        if (this.hasNextBtnTarget) {
          this.nextBtnTarget.style.display = "inline-flex"
        }
      }
    }
  }

  async submitMonopoleQuote() {
    const school = this.hasMonopoleSchoolInputTarget ? this.monopoleSchoolInputTarget.value.trim() : ""
    const email = this.hasMonopoleEmailInputTarget ? this.monopoleEmailInputTarget.value.trim() : ""
    const message = this.hasMonopoleMessageInputTarget ? this.monopoleMessageInputTarget.value.trim() : ""

    if (!school) {
      alert("Veuillez indiquer le nom de votre établissement.")
      if (this.hasMonopoleSchoolInputTarget) this.monopoleSchoolInputTarget.focus()
      return
    }

    if (!email || !email.includes("@")) {
      alert("Veuillez indiquer une adresse email valide.")
      if (this.hasMonopoleEmailInputTarget) this.monopoleEmailInputTarget.focus()
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

      alert("Merci ! Votre demande de devis Monopole a bien été transmise à notre équipe. Nous vous contacterons sous 24h avec une proposition personnalisée.")
      window.location.href = "/schools-ads"
    } catch (error) {
      console.error("Erreur monopole quote:", error)
      alert("Une erreur est survenue. Veuillez réessayer ou nous contacter directement à contact@omniscientdesign.fr.")
    }
  }

  selectFormat(event) {
    const pill = event.currentTarget
    const format = pill.dataset.format

    this.formatPillTargets.forEach(p => p.classList.toggle("sa-pill--active", p === pill))
    this.selectedFormat = format
  }

  selectDevice(event) {
    const pill = event.currentTarget
    const device = pill.dataset.device

    this.devicePillTargets.forEach(p => p.classList.toggle("sa-pill--active", p === pill))
    this.selectedDevice = device

    if (this.hasPreviewFrameTarget) {
      this.previewFrameTarget.classList.toggle("sa-preview-frame--mobile", device === "mobile")
      this.previewFrameTarget.classList.toggle("sa-preview-frame--pc", device === "pc")
    }

    if (this.hasPreviewDeviceLabelTarget) {
      this.previewDeviceLabelTarget.textContent = device === "mobile" ? "Visuel sur Mobile" : "Visuel sur PC"
    }

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

    if (this.hasPreviewTitleTarget) this.previewTitleTarget.textContent = title
    if (this.hasPreviewDescTarget) this.previewDescTarget.textContent = desc
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

  displayFileInPreview(file) {
    const isVideo = file.type.startsWith("video/")
    const isImage = file.type.startsWith("image/")

    if (!isImage && !isVideo) {
      alert("Veuillez sélectionner un fichier image ou vidéo valide.")
      return
    }

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
    if (!this.rangeStart || (this.rangeStart && this.rangeEnd)) {
      this.rangeStart = date
      this.rangeEnd = null
    } else if (this.rangeStart && !this.rangeEnd) {
      if (date < this.rangeStart) {
        this.rangeEnd = this.rangeStart
        this.rangeStart = date
      } else {
        this.rangeEnd = date
      }
    }

    this.renderCalendar()
    this.updateDatesDisplay()
  }

  updateDatesDisplay() {
    const formatDate = (d) => {
      if (!d) return "19/01/2026"
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
      const diffTime = Math.abs(this.rangeEnd - this.rangeStart)
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1
      this.durationSummaryTarget.textContent = `${diffDays} jours de diffusion planifiés`
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
      formData.append("format_type", this.selectedFormat)
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
        alert(result.message || "Une erreur est survenue lors de l'initialisation du paiement.")
        nextBtn.disabled = false
        nextBtn.innerHTML = originalText
      }
    } catch (error) {
      console.error("Erreur checkout:", error)
      alert("Erreur de connexion au serveur de paiement. Veuillez réessayer.")
      nextBtn.disabled = false
      nextBtn.innerHTML = originalText
    }
  }
}
