import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "badgeItem",
    "mobileMenu",
    "previewTab",
    "previewScreen",
    "formFeedback",
    "contactForm",
    "schoolInput",
    "mapTooltip",
    "tooltipRegion",
    "tooltipCount",
    "tooltipPercent"
  ]

  connect() {
    this.initBadgeRotation()
  }

  disconnect() {
    if (this.badgeInterval) {
      clearInterval(this.badgeInterval)
    }
  }

  // --- INTERACTIVE FRANCE MAP TOOLTIP ---
  showRegionTooltip(event) {
    const regionEl = event.currentTarget
    const regionName = regionEl.dataset.region
    const count = regionEl.dataset.count
    const percent = regionEl.dataset.percent

    if (this.hasMapTooltipTarget) {
      if (this.hasTooltipRegionTarget) this.tooltipRegionTarget.textContent = regionName
      if (this.hasTooltipCountTarget) this.tooltipCountTarget.textContent = `${count} membres`
      if (this.hasTooltipPercentTarget) this.tooltipPercentTarget.textContent = `${percent} de l'audience`

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
    const wrapper = tooltip.closest(".sa-audience__map-wrapper")
    if (!wrapper) return

    const rect = wrapper.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top

    tooltip.style.left = `${x}px`
    tooltip.style.top = `${y}px`
  }

  initBadgeRotation() {
    const items = this.badgeItemTargets
    if (!items || items.length <= 1) return
    
    this.currentBadgeIndex = 0

    this.badgeInterval = setInterval(() => {
      this.rotateBadge()
    }, 3000)
  }

  rotateBadge() {
    const items = this.badgeItemTargets
    if (!items || items.length <= 1) return

    const currentItem = items[this.currentBadgeIndex]
    this.currentBadgeIndex = (this.currentBadgeIndex + 1) % items.length
    const nextItem = items[this.currentBadgeIndex]

    if (currentItem && nextItem) {
      currentItem.classList.remove("sa-badge-item--active")
      currentItem.classList.add("sa-badge-item--exiting")

      setTimeout(() => {
        currentItem.classList.remove("sa-badge-item--exiting")
      }, 400)

      nextItem.classList.add("sa-badge-item--active")
    }
  }

  toggleMobileMenu() {
    const menu = document.getElementById("sa-mobile-menu")
    if (menu) {
      menu.classList.toggle("sa-mobile-menu--open")
    }
  }

  // Onglets de prévisualisation des formats d'intégration
  switchPreview(event) {
    const selectedTab = event.currentTarget
    const formatType = selectedTab.dataset.format

    // Mettre à jour l'état actif des boutons
    this.previewTabTargets.forEach(tab => {
      tab.classList.toggle("sa-integration__nav-btn--active", tab === selectedTab)
    })

    // Afficher l'écran/l'image correspondant
    this.previewScreenTargets.forEach(screen => {
      screen.classList.toggle("sa-integration__preview-card--active", screen.dataset.format === formatType)
    })
  }

  // FAQ Accordéon
  toggleFaq(event) {
    const button = event.currentTarget
    const accordionItem = button.closest(".sa-faq__item")
    const isOpen = accordionItem.classList.contains("sa-faq__item--open")

    // Fermer les autres accordéons
    document.querySelectorAll(".sa-faq__item").forEach(item => {
      item.classList.remove("sa-faq__item--open")
    })

    if (!isOpen) {
      accordionItem.classList.add("sa-faq__item--open")
    }
  }

  // Sélection d'un pack depuis les cartes de tarifs
  selectPlan(event) {
    const planName = event.currentTarget.dataset.plan
    const messageField = document.getElementById("sa_message")
    const formSection = document.getElementById("contact")

    if (formSection) {
      formSection.scrollIntoView({ behavior: "smooth" })
    }

    if (messageField && planName) {
      messageField.value = `Bonjour, nous sommes intéressés par la formule "${planName}". Pouvons-nous échanger à ce sujet ?`
      messageField.focus()
    }
  }
}
