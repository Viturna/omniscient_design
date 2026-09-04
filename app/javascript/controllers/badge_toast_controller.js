import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "container", 
    "toast", 
    "image", 
    "tag", 
    "title", 
    "desc", 
    "progressSection", 
    "progressBar", 
    "progressCurrent", 
    "progressTarget", 
    "progressRemaining",
    "link"
  ]

  connect() {
    // Écoute les événements globaux 'badge:unlocked' et 'badge:progress'
    this.handleBadgeUnlocked = this.handleBadgeUnlocked.bind(this)
    this.handleBadgeProgress = this.handleBadgeProgress.bind(this)

    window.addEventListener("badge:unlocked", this.handleBadgeUnlocked)
    window.addEventListener("badge:progress", this.handleBadgeProgress)
  }

  disconnect() {
    window.removeEventListener("badge:unlocked", this.handleBadgeUnlocked)
    window.removeEventListener("badge:progress", this.handleBadgeProgress)
    if (this.timeout) clearTimeout(this.timeout)
  }

  handleBadgeUnlocked(event) {
    const badge = event.detail
    if (!badge) return

    this.show({
      isUnlock: true,
      tag: "Badge débloqué",
      title: badge.name,
      desc: badge.description || "Félicitations, tu as remporté ce badge !",
      imageName: badge.image_name,
      showProgress: false
    })
  }

  handleBadgeProgress(event) {
    const progress = event.detail
    if (!progress) return

    this.show({
      isUnlock: false,
      tag: "Progression badge",
      title: progress.name,
      desc: `Plus que ${progress.remaining} pts pour atteindre ce palier.`,
      imageName: progress.image_name,
      showProgress: true,
      progress: progress
    })
  }

  show({ isUnlock, tag, title, desc, imageName, showProgress, progress }) {
    if (this.timeout) clearTimeout(this.timeout)

    // Définir les textes
    if (this.hasTagTarget) {
      this.tagTarget.textContent = tag
      this.tagTarget.className = isUnlock ? "toast-tag tag-unlock" : "toast-tag tag-progress"
    }
    if (this.hasTitleTarget) this.titleTarget.textContent = title
    if (this.hasDescTarget) this.descTarget.textContent = desc

    // Image
    if (this.hasImageTarget) {
      if (imageName) {
        const cleanName = imageName.replace(/\.png$/, '.webp')
        this.imageTarget.src = `/assets/badges/${cleanName}`
      } else {
        this.imageTarget.src = "/assets/badges/default.webp"
      }
    }

    // Barre de progression
    if (this.hasProgressSectionTarget) {
      if (showProgress && progress) {
        this.progressSectionTarget.classList.remove("hidden")
        if (this.hasProgressBarTarget) {
          setTimeout(() => {
            this.progressBarTarget.style.width = `${progress.percentage || 0}%`
          }, 100)
        }
        if (this.hasProgressCurrentTarget) this.progressCurrentTarget.textContent = progress.current
        if (this.hasProgressTargetTarget) this.progressTargetTarget.textContent = progress.target
        if (this.hasProgressRemainingTarget) this.progressRemainingTarget.textContent = `${progress.remaining} pts restants`
      } else {
        this.progressSectionTarget.classList.add("hidden")
      }
    }

    // Afficher le toast avec animation
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove("hidden")
      this.containerTarget.classList.add("visible")
    }

    // Fermeture automatique après 6 secondes
    this.timeout = setTimeout(() => {
      this.close()
    }, 6500)
  }

  close() {
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove("visible")
      setTimeout(() => {
        this.containerTarget.classList.add("hidden")
      }, 400)
    }
    if (this.timeout) clearTimeout(this.timeout)
  }
}
