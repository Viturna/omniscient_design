// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content", "footer"]

  connect() {
    // Vérification immédiate
    if (sessionStorage.getItem("loaderSeen") === "true") {
      this.hideImmediately();
    } else {
      this.playAnimation();
    }
  }

  playAnimation() {
    // On fige le scroll
    document.body.classList.add('overflow-hidden');
    
    // Le loader est visible par défaut via CSS, on attend juste la fin
    // Sécurité de 3.5s pour laisser la vidéo jouer
    setTimeout(() => {
      this.finish();
    }, 3500);
  }

  finish() {
    // On mémorise que l'utilisateur a vu l'intro
    sessionStorage.setItem("loaderSeen", "true");
    this.hideWithTransition();
  }

  hideWithTransition() {
    // On ajoute la classe CSS qui gère l'opacité
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("is-hidden");
      
      // Une fois la transition CSS finie (500ms), on nettoie
      setTimeout(() => {
        this.loadingTarget.style.display = "none"; // Retrait du flux
        document.body.classList.remove('overflow-hidden');
      }, 500);
    }
  }

  hideImmediately() {
    // Cas où on revient sur le site : suppression instantanée
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "none";
      this.loadingTarget.classList.add("is-hidden");
    }
    document.body.classList.remove('overflow-hidden');
  }
}