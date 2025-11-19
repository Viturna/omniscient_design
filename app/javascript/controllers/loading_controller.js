// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content", "footer"]

  connect() {
    if (sessionStorage.getItem("loaderSeen") === "true") {
      this.hideImmediately();
    } else {
      this.playAnimation();
    }
  }

  playAnimation() {
    document.body.classList.add('overflow-hidden');

    this.loadingTarget.style.display = "flex";

    setTimeout(() => {
      this.finish();
    }, 3500);
  }

  finish() {
    sessionStorage.setItem("loaderSeen", "true");

    this.loadingTarget.style.opacity = "0";

    setTimeout(() => {
      this.hideImmediately();
    }, 500);
  }

  hideImmediately() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "none";
      this.loadingTarget.style.opacity = "0"; // Pour être sûr
    }

    if (this.hasContentTarget) this.contentTarget.style.display = "block";
    if (this.hasFooterTarget) this.footerTarget.style.display = "block";

    document.body.classList.remove('overflow-hidden');
  }
}