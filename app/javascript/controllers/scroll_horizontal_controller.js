import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "prevBtn", "nextBtn"]

  connect() {
    this.isDown = false
    this.startX = 0
    this.scrollLeftPos = 0
    this.scrollContainer = this.hasTrackTarget ? this.trackTarget : this.element

    this.onMouseDownBound = this.onMouseDown.bind(this)
    this.onMouseLeaveBound = this.onMouseLeave.bind(this)
    this.onMouseUpBound = this.onMouseUp.bind(this)
    this.onMouseMoveBound = this.onMouseMove.bind(this)
    this.updateArrowsBound = this.updateArrows.bind(this)

    // Drag events
    this.scrollContainer.addEventListener("mousedown", this.onMouseDownBound)
    window.addEventListener("mouseup", this.onMouseUpBound)
    window.addEventListener("mouseleave", this.onMouseLeaveBound)
    this.scrollContainer.addEventListener("mousemove", this.onMouseMoveBound)
    this.scrollContainer.addEventListener("scroll", this.updateArrowsBound, { passive: true })

    // Ensure it starts aligned at scrollLeft 0
    this.scrollContainer.scrollLeft = 0
    this.updateArrows()
  }

  disconnect() {
    this.scrollContainer.removeEventListener("mousedown", this.onMouseDownBound)
    window.removeEventListener("mouseup", this.onMouseUpBound)
    window.removeEventListener("mouseleave", this.onMouseLeaveBound)
    this.scrollContainer.removeEventListener("mousemove", this.onMouseMoveBound)
    this.scrollContainer.removeEventListener("scroll", this.updateArrowsBound)
  }

  onMouseDown(e) {
    if (e.button !== 0) return
    this.isDown = true
    this.scrollContainer.classList.add("active")
    this.startX = e.pageX - this.scrollContainer.offsetLeft
    this.scrollLeftPos = this.scrollContainer.scrollLeft
  }

  onMouseLeave() {
    this.isDown = false
    this.scrollContainer.classList.remove("active")
  }

  onMouseUp() {
    this.isDown = false
    this.scrollContainer.classList.remove("active")
  }

  onMouseMove(e) {
    if (!this.isDown) return
    e.preventDefault()
    const x = e.pageX - this.scrollContainer.offsetLeft
    const walk = (x - this.startX) * 1.5
    this.scrollContainer.scrollLeft = this.scrollLeftPos - walk
  }

  scrollPrev(e) {
    if (e) e.preventDefault()
    const amount = (this.scrollContainer.clientWidth * 0.75) || 360
    this.scrollContainer.scrollBy({ left: -amount, behavior: "smooth" })
  }

  scrollNext(e) {
    if (e) e.preventDefault()
    const amount = (this.scrollContainer.clientWidth * 0.75) || 360
    this.scrollContainer.scrollBy({ left: amount, behavior: "smooth" })
  }

  updateArrows() {
    const sl = this.scrollContainer.scrollLeft
    const maxScroll = this.scrollContainer.scrollWidth - this.scrollContainer.clientWidth

    if (this.hasPrevBtnTarget) {
      const atStart = sl <= 5
      this.prevBtnTarget.disabled = atStart
      this.prevBtnTarget.style.opacity = atStart ? "0.3" : "1"
      this.prevBtnTarget.style.pointerEvents = atStart ? "none" : "auto"
    }

    if (this.hasNextBtnTarget) {
      const atEnd = sl >= maxScroll - 5
      this.hasNextBtnTarget.disabled = atEnd
      this.hasNextBtnTarget.style.opacity = atEnd ? "0.3" : "1"
      this.hasNextBtnTarget.style.pointerEvents = atEnd ? "none" : "auto"
    }
  }
}
