import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "text", "icon"]

  connect() {
    this.startX = 0
    this.isDragging = false
    this.hasDragged = false
    this.isOpen = false
    this.visibleWidth = 82 // Matches the CSS calc(-100% + 82px)
  }

  get isRightSide() {
    return window.innerWidth <= 768;
  }

  setTransform(x) {
    if (this.isRightSide) {
      this.element.style.transform = `translateY(-50%) translateX(${x}px)`
    } else {
      this.element.style.transform = `translateX(${x}px)`
    }
  }

  dragStart(e) {
    this.isDragging = true
    this.hasDragged = false
    this.startX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX
    
    let hiddenWidth = this.element.offsetWidth - this.visibleWidth
    this.closedTranslate = this.isRightSide ? hiddenWidth : -hiddenWidth
    this.startTranslate = this.isOpen ? 0 : this.closedTranslate
    
    this.element.style.transition = 'none'
    this.element.classList.remove('animate-pulse')
  }

  dragMove(e) {
    if (!this.isDragging) return
    
    let clientX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX
    let deltaX = clientX - this.startX

    if (Math.abs(deltaX) > 5) {
      this.hasDragged = true
    }

    let newTranslate = this.startTranslate + deltaX
    
    if (this.isRightSide) {
      if (newTranslate < 0) {
        newTranslate = newTranslate * 0.2
      }
    } else {
      if (newTranslate > 0) {
        newTranslate = newTranslate * 0.2
      }
    }

    this.setTransform(newTranslate)
  }

  dragEnd(e) {
    if (!this.isDragging) return
    this.isDragging = false
    this.element.style.transition = 'transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1)'

    let clientX = e.type.includes('touch') ? e.changedTouches[0].clientX : e.clientX
    let deltaX = clientX - this.startX
    let newTranslate = this.startTranslate + deltaX

    if (this.isRightSide) {
      if (newTranslate > this.closedTranslate + 30) {
        this.setTransform(this.closedTranslate + 150)
        setTimeout(() => { this.close() }, 400)
        return
      }
      let midPoint = this.closedTranslate / 2
      if (newTranslate < midPoint) {
        this.openTab()
      } else {
        this.closeTab()
      }
    } else {
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
    this.element.style.transform = ''
  }

  close(e) {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    this.element.style.display = "none"
  }
}
