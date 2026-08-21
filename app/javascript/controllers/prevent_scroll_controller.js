import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('wheel', this.preventScroll, { passive: false })
  }

  disconnect() {
    this.element.removeEventListener('wheel', this.preventScroll)
  }

  preventScroll = (e) => {
    const el = this.element
    const scrollTop = el.scrollTop
    const scrollHeight = el.scrollHeight
    const offsetHeight = el.offsetHeight
    const deltaY = e.deltaY

    const isAtTop = scrollTop === 0
    const isAtBottom = scrollTop + offsetHeight >= scrollHeight - 1 // -1 for subpixel rounding

    if ((isAtTop && deltaY < 0) || (isAtBottom && deltaY > 0)) {
      e.preventDefault()
    }
    // Stop the event from bubbling up to the window
    e.stopPropagation()
  }
}
