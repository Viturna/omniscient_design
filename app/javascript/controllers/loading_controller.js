// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content", "footer"]

  connect() {
    this.init()
    document.addEventListener("turbo:load", () => this.init())
    document.addEventListener("turbo:before-render", () => this.showLoading())
  }

  init() {
    requestAnimationFrame(() => this.showContent())
  }

  showLoading() {
    if (this.hasLoadingTarget) this.loadingTarget.style.display = "flex"
    if (this.hasContentTarget) this.contentTarget.style.display = "none"
    if (this.hasFooterTarget) this.footerTarget.style.display = "none"
  }

  showContent() {
    if (this.hasLoadingTarget) this.loadingTarget.style.display = "none"
    if (this.hasContentTarget) this.contentTarget.style.display = "block"
    if (this.hasFooterTarget) this.footerTarget.style.display = "block"
  }
}
