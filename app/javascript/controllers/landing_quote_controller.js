import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "word"]

  connect() {
    this.activeIndex = 0
    this.totalWords = this.wordTargets.length
    
    // Attendre un court instant que le layout soit complètement peint
    this.initTimeout = setTimeout(() => {
      this.init()
    }, 200)

    // Écouter le défilement de la page
    this.scrollHandler = this.onScroll.bind(this)
    window.addEventListener("scroll", this.scrollHandler)

    // Gérer les redimensionnements
    this.resizeHandler = this.handleResize.bind(this)
    window.addEventListener("resize", this.resizeHandler)
  }

  disconnect() {
    window.removeEventListener("scroll", this.scrollHandler)
    window.removeEventListener("resize", this.resizeHandler)
    clearTimeout(this.initTimeout)
  }

  init() {
    const gsap = window.gsap
    if (!gsap) {
      console.warn("GSAP n'est pas encore disponible.")
      return
    }

    this.calculateRowHeight()
    this.updateWords(true) // Applique l'état initial sans animation
    this.onScroll() // Déclenche un premier calcul au chargement
  }

  handleResize() {
    this.calculateRowHeight()
    this.updateWords(true)
  }

  calculateRowHeight() {
    this.rowHeight = this.wordTargets[0]?.offsetHeight || 50
  }

  onScroll() {
    const gsap = window.gsap
    if (!gsap) return

    const rect = this.element.getBoundingClientRect()
    const viewportHeight = window.innerHeight

    // Zone active : de 85% à 15% de la hauteur de l'écran
    const start = viewportHeight * 0.85
    const end = viewportHeight * 0.15

    // Hors-champ (avant la section) -> premier mot
    if (rect.top > start) {
      if (this.activeIndex !== 0) {
        this.activeIndex = 0
        this.updateWords()
      }
      return
    }

    // Hors-champ (après la section) -> dernier mot
    if (rect.bottom < end) {
      if (this.activeIndex !== this.totalWords - 1) {
        this.activeIndex = this.totalWords - 1
        this.updateWords()
      }
      return
    }

    // Calcul du pourcentage de progression du scroll dans la zone active (entre 0 et 1)
    const totalDistance = start - end
    const currentDistance = start - rect.top
    let progress = currentDistance / totalDistance
    progress = Math.max(0, Math.min(1, progress))

    // Mapping du pourcentage vers l'index du mot (0 à 4)
    const activeIndex = Math.floor(progress * this.totalWords)
    const clampedIndex = Math.max(0, Math.min(this.totalWords - 1, activeIndex))

    if (clampedIndex !== this.activeIndex) {
      this.activeIndex = clampedIndex
      this.updateWords()
    }
  }

  updateWords(immediate = false) {
    const gsap = window.gsap
    if (!gsap) return

    const duration = immediate ? 0 : 0.5
    const ease = "power2.out"

    // Calcul du décalage y pour centrer le mot actif (formule d'alignement vertical)
    const targetY = (2 - this.activeIndex) * this.rowHeight

    gsap.to(this.listTarget, {
      y: targetY,
      duration: duration,
      ease: ease,
      overwrite: "auto"
    })

    // Animation individuelle de l'opacité et de l'échelle de chaque mot
    this.wordTargets.forEach((word, idx) => {
      const distance = Math.abs(idx - this.activeIndex)
      let opacity = 0
      let scale = 0.95

      if (distance === 0) {
        opacity = 1
        scale = 1
      } else if (distance === 1) {
        opacity = 0.4
        scale = 0.95
      } else if (distance === 2) {
        opacity = 0.15
        scale = 0.9
      } else {
        opacity = 0.05
        scale = 0.9
      }

      gsap.to(word, {
        opacity: opacity,
        scale: scale,
        duration: duration,
        ease: ease,
        overwrite: "auto"
      })
    })
  }
}
