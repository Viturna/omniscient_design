import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() {
    document.addEventListener("turbo:load", () => this.init())
    this.lastScrollTop = 0
    this.scrollHandler = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.scrollHandler)
  }

  disconnect() {
    window.removeEventListener("scroll", this.scrollHandler)
  }

  handleScroll() {
    const scrollThreshold = 50
    const currentScroll = window.pageYOffset || document.documentElement.scrollTop
    const header = document.querySelector('.header-show')
    const text = document.querySelector('.text-show')
    const infos = document.querySelector('.header-top')
    const firstContent = document.querySelector('.info-card-first-content')

    if (!header || !text || !infos || !firstContent) return

    if (currentScroll > this.lastScrollTop && currentScroll > scrollThreshold) {
      firstContent.classList.add('hidden')
      infos.classList.add('show-header-top')
      header.classList.add('small-height')
      text.classList.add('small-height')
    } else if (currentScroll <= scrollThreshold) {
      firstContent.classList.remove('hidden')
      infos.classList.remove('show-header-top')
      header.classList.remove('small-height')
      text.classList.remove('small-height')
    }

    this.lastScrollTop = Math.max(currentScroll, 0)
  }
}
