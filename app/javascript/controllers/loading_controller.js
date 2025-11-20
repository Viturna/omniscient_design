// app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content", "footer"]

  connect() {
    // Si déjà vu, on cache tout de suite
    if (sessionStorage.getItem("loaderSeen") === "true") {
      this.hideImmediately();
    } else {
      this.playAnimation();
    }
  }

  playAnimation() {
    document.body.classList.add('overflow-hidden');
    this.loadingTarget.style.display = "flex";

    // --- CHANGEMENT ICI ---
    // On vérifie l'état du chargement réel de la page

    if (document.readyState === "complete") {
      // Cas 1 : Le site est déjà chargé quand le contrôleur se connecte (connexion très rapide)
      this.finish();
    } else {
      // Cas 2 : Le site charge encore, on attend l'événement de fin de chargement
      window.addEventListener("load", () => {
        this.finish();
      }, { once: true }); // { once: true } nettoie l'écouteur automatiquement après usage
    }

    // Sécurité : Si jamais le "load" ne se déclenche pas (ex: un script tiers plante), 
    // on force l'ouverture après 5 secondes max pour ne pas bloquer l'utilisateur.
    setTimeout(() => {
      if (document.body.classList.contains('overflow-hidden')) {
        this.finish();
      }
    }, 5000);
  }

  finish() {
    sessionStorage.setItem("loaderSeen", "true");

    // Petit délai de confort (500ms) pour voir au moins un tout petit peu le logo/vidéo
    // Si vous voulez de l'instantané pur, mettez 0 ou enlevez le setTimeout
    setTimeout(() => {
      this.loadingTarget.style.opacity = "0";
      this.hideWithTransition();
    }, 500);
  }

  hideWithTransition() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("is-hidden");

      // On attend la fin de la transition CSS (0.5s) pour retirer du DOM
      setTimeout(() => {
        this.loadingTarget.style.display = "none";
        document.body.classList.remove('overflow-hidden');
      }, 500);
    }
  }

  hideImmediately() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "none";
      this.loadingTarget.classList.add("is-hidden");
    }

    // On s'assure que le contenu est affiché
    if (this.hasContentTarget) this.contentTarget.style.display = "block";
    if (this.hasFooterTarget) this.footerTarget.style.display = "block";

    document.body.classList.remove('overflow-hidden');
  }
}