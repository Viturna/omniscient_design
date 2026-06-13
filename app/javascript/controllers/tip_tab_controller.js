import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "text", "icon"]

  connect() {
    if (sessionStorage.getItem('tipClicked')) {
      this.element.style.display = "none"
      return
    }

    this.startX = 0
    this.isDragging = false
    this.hasDragged = false
    this.isOpen = false
    this.visibleWidth = 82 // Matches the CSS calc(-100% + 82px)
  }

  get isMobile() {
    return window.innerWidth <= 768;
  }

  setTransform(x) {
    if (this.isMobile) {
      this.element.style.transform = `translateY(-50%) translateX(${x}px)`
    } else {
      this.element.style.transform = `translateX(${x}px)`
    }
  }

  dragStart(e) {
    if (sessionStorage.getItem('tipClicked')) return
    
    this.isDragging = true
    this.hasDragged = false
    this.startX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX
    
    let hiddenWidth = this.element.offsetWidth - this.visibleWidth
    this.closedTranslate = -hiddenWidth
    this.startTranslate = this.isOpen ? 0 : this.closedTranslate
    
    this.element.style.transition = 'none'
    this.element.classList.remove('animate-pulse')
  }

  dragMove(e) {
    if (!this.isDragging || sessionStorage.getItem('tipClicked')) return
    
    let clientX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX
    let deltaX = clientX - this.startX

    if (Math.abs(deltaX) > 5) {
      this.hasDragged = true
    }

    let newTranslate = this.startTranslate + deltaX
    
    // Bloque si on tire plus loin que l'ouverture (0)
    if (newTranslate > 0) {
      newTranslate = 0
    }

    this.setTransform(newTranslate)
  }

  dragEnd(e) {
    if (!this.isDragging || sessionStorage.getItem('tipClicked')) return
    this.isDragging = false
    this.element.style.transition = 'transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1)'

    let clientX = e.type.includes('touch') ? e.changedTouches[0].clientX : e.clientX
    let deltaX = clientX - this.startX
    let newTranslate = this.startTranslate + deltaX

    if (newTranslate < this.closedTranslate - 30) {
      this.setTransform(this.closedTranslate - 150)
      setTimeout(() => { this.close() }, 400)
      return
    }
    
    let midPoint = this.closedTranslate / 2
    if (newTranslate > midPoint) {
      this.openTab()
    } else {
      this.closeTab()
    }

    setTimeout(() => { this.hasDragged = false }, 50)
  }

  openTab() {
    this.isOpen = true
    this.element.classList.add("expanded")
    this.element.classList.remove("animate-pulse")
    this.element.style.transform = '' // Let CSS handle it
  }

  closeTab() {
    this.isOpen = false
    this.element.classList.remove("expanded")
    this.element.classList.add("animate-pulse")
    this.element.style.transform = '' // Let CSS handle it
  }

  navigate(e) {
    if (this.hasDragged) {
      if (e) {
        e.preventDefault()
        e.stopPropagation()
      }
      return
    }
    
    // Log click in background
    fetch("/fr/tip_clicks", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      }
    }).catch(() => {})

    window.open("https://fr.tipeee.com/le-site-omniscient-design", "_blank")
    
    // Hide the tab for the current session
    sessionStorage.setItem('tipClicked', 'true')
    this.close()
  }

  close(e) {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    this.element.style.display = "none"
  }
}
