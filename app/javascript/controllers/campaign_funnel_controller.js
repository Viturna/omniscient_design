import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    // Step panels
    "stepPanel",
    "stepBadge",
    "stepTitle",
    "stepSubtitle",
    "prevBtn",
    "nextBtn",
    "nextBtnText",
    
    // Step 1 : Visuels & Preview
    "formatPill",
    "devicePill",
    "imageInput",
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
    "previewFormatLabel",
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
    "selectedRegionLabel",
    
    // Step 4 : Compte & Récap
    "schoolNameInput",
    "emailInput",
    "contactNameInput",
    "recapFormat",
    "recapDates",
    "recapRegion",
    "recapPrice"
  ]

  connect() {
    this.currentStep = 1
    this.totalSteps = 4
    
    // Form data state
    this.selectedFormat = "accueil"
    this.selectedDevice = "pc"
    this.selectedRegionKey = "cvl" // Centre-Val de Loire par défaut comme sur la maquette
    
    // Calendar state
    this.currentDate = new Date(2026, 8, 1) // Septembre 2026
    this.rangeStart = new Date(2026, 8, 7) // 7 Septembre
    this.rangeEnd = new Date(2026, 8, 31) // 31 Septembre
    
    // Initial renders
    this.updateStepView()
    this.renderCalendar()
    this.updateDatesDisplay()
    this.selectRegion("cvl")
  }

  // =========================================================================
  // 1. STEP NAVIGATION
  // =========================================================================

  goToStep(event) {
    const step = parseInt(event.currentTarget.dataset.step)
    if (step && step >= 1 && step <= this.totalSteps) {
      this.currentStep = step
      this.updateStepView()
    }
  }

  nextStep() {
    if (this.currentStep < this.totalSteps) {
      this.currentStep++
      this.updateStepView()
    } else {
      this.submitCampaign()
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--
      this.updateStepView()
    }
  }

  updateStepView() {
    // 1. Switch left form panels
    this.stepPanelTargets.forEach(panel => {
      const panelStep = parseInt(panel.dataset.step)
      panel.classList.toggle("sa-funnel__panel--active", panelStep === this.currentStep)
    })

    // 2. Update Header Titles
    const stepConfig = {
      1: {
        badge: "Étape 1/4 : Visuels",
        subtitle: "Configuration des visuels de votre campagne",
        nextText: "Calendrier de diffusion",
        showPrev: false
      },
      2: {
        badge: "Étape 2/4 : Calendrier de diffusion",
        subtitle: "Configuration de la période de votre campagne",
        nextText: "Encrage local",
        showPrev: true,
        prevText: "Modifier les visuels"
      },
      3: {
        badge: "Étape 3/4 : Configurer l’encrage local",
        subtitle: "Région que vous souhaitez cibler",
        nextText: "Création du compte",
        showPrev: true,
        prevText: "Modifier le calendrier"
      },
      4: {
        badge: "Étape 4/4 : Création du compte & Récapitulatif",
        subtitle: "Vos coordonnées et validation de votre campagne",
        nextText: "Confirmer & Payer en ligne",
        showPrev: true,
        prevText: "Modifier l’encrage"
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

    // 4. Update recap on step 4
    if (this.currentStep === 4) {
      this.updateRecap()
    }

    // Scroll to top of funnel container
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  // =========================================================================
  // 2. ÉTAPE 1 : VISUELS, FORMATS & LIVE PREVIEW
  // =========================================================================

  selectFormat(event) {
    const pill = event.currentTarget
    const format = pill.dataset.format

    this.formatPillTargets.forEach(p => p.classList.toggle("sa-pill--active", p === pill))
    this.selectedFormat = format

    const formatLabels = {
      accueil: "Page d’accueil",
      recherche: "Page de recherche",
      quiz: "Quiz de la semaine"
    }

    if (this.hasPreviewFormatLabelTarget) {
      this.previewFormatLabelTarget.textContent = formatLabels[format] || "Page d'accueil"
    }
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

  triggerUpload() {
    if (this.hasImageInputTarget) {
      this.imageInputTarget.click()
    }
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.previewUploadedFile(file)
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
      this.previewUploadedFile(file)
    }
  }

  previewUploadedFile(file) {
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

    // Jours du mois
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
      if (!d) return "Sélectionner"
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
      occ: "Occitanie",
      hdf: "Hauts-de-France",
      pac: "Provence-Alpes-Côte d'Azur",
      ges: "Grand Est",
      pdl: "Pays de la Loire",
      nor: "Normandie",
      bfc: "Bourgogne-Franche-Comté",
      cor: "Corse"
    }

    const regionEstimations = {
      cvl: 120,
      idf: 457,
      bre: 84,
      naq: 142,
      ara: 198,
      occ: 128,
      hdf: 102,
      pac: 89,
      ges: 78,
      pdl: 68,
      nor: 56,
      bfc: 48,
      cor: 14
    }

    const name = regionNames[regionKey] || "France entière"
    const count = regionEstimations[regionKey] || 120

    if (this.hasRegionSearchInputTarget) {
      this.regionSearchInputTarget.value = name
    }

    if (this.hasStudentCountTarget) {
      this.studentCountTarget.textContent = `${count} étudiants`
    }

    if (this.hasSelectedRegionLabelTarget) {
      this.selectedRegionLabelTarget.textContent = name
    }
  }

  filterRegions(event) {
    const query = event.target.value.toLowerCase().trim()
    if (!query) return

    const matchKey = Object.keys({
      idf: "île-de-france",
      bre: "bretagne finistère",
      naq: "nouvelle-aquitaine",
      ara: "auvergne-rhône-alpes",
      occ: "occitanie",
      hdf: "hauts-de-france",
      pac: "provence-alpes-côte d'azur",
      ges: "grand est",
      pdl: "pays de la loire",
      nor: "normandie",
      bfc: "bourgogne-franche-comté",
      cvl: "centre-val de loire",
      cor: "corse"
    }).find(key => key.includes(query) || (key === "bre" && query.includes("fini")))

    if (matchKey) {
      this.selectRegion(matchKey)
    }
  }

  // =========================================================================
  // 5. ÉTAPE 4 : RÉCAPITULATIF & SOUMISSION
  // =========================================================================

  updateRecap() {
    const formatLabels = {
      accueil: "Encart Page d'accueil",
      recherche: "Encart Page de recherche",
      quiz: "Sponsoring Quiz de la semaine"
    }

    const regionNames = {
      cvl: "Centre-Val de Loire",
      idf: "Île-de-France",
      bre: "Bretagne",
      naq: "Nouvelle-Aquitaine",
      ara: "Auvergne-Rhône-Alpes",
      occ: "Occitanie",
      hdf: "Hauts-de-France",
      pac: "Provence-Alpes-Côte d'Azur",
      ges: "Grand Est",
      pdl: "Pays de la Loire",
      nor: "Normandie",
      bfc: "Bourgogne-Franche-Comté",
      cor: "Corse"
    }

    if (this.hasRecapFormatTarget) {
      this.recapFormatTarget.textContent = formatLabels[this.selectedFormat] || "Encart Page d'accueil"
    }

    if (this.hasRecapDatesTarget && this.rangeStart && this.rangeEnd) {
      const formatDate = (d) => `${d.getDate()} ${d.toLocaleString('fr-FR', { month: 'short' })} ${d.getFullYear()}`
      this.recapDatesTarget.textContent = `${formatDate(this.rangeStart)} au ${formatDate(this.rangeEnd)}`
    }

    if (this.hasRecapRegionTarget) {
      this.recapRegionTarget.textContent = regionNames[this.selectedRegionKey] || "Ancrage Local"
    }

    if (this.hasRecapPriceTarget) {
      this.recapPriceTarget.textContent = "400€ TTC"
    }
  }

  submitCampaign() {
    const schoolName = this.hasSchoolNameInputTarget ? this.schoolNameInputTarget.value.trim() : ""
    const email = this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : ""

    if (!schoolName || !email) {
      alert("Veuillez renseigner le nom de votre établissement et votre adresse e-mail.")
      return
    }

    alert(`Félicitations ! Votre campagne pour "${schoolName}" a été enregistrée avec succès. Redirection vers l'espace de paiement sécurisé Stripe...`)
  }
}
