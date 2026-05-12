import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notion-toggle"
export default class extends Controller {
  static targets = ["content", "chevron"]

  toggle(event) {
    const group = event.currentTarget.closest(".notion-theme-group")
    const content = group.querySelector('[data-notion-toggle-target="content"]')
    const chevron = group.querySelector('[data-notion-toggle-target="chevron"]')

    const isMobile = window.matchMedia("(max-width: 768px)").matches
    const rotation = isMobile ? "90deg" : "180deg"

    if (content.style.display === "none") {
      content.style.display = "flex"
      if (chevron) chevron.style.transform = `rotate(${rotation})`
    } else {
      content.style.display = "none"
      if (chevron) chevron.style.transform = "rotate(0deg)"
    }
  }
}
