import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  trigger(event) {
    event.preventDefault();
    
    // 1. Définir une URL par défaut (Fallback pour Desktop)
    let url = "https://www.google.com/search?q=Omniscient+Design";
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;

    // IDs
    const iosAppId = "6754964970";
    const androidPackage = "com.thomasriq.omniscientdesign";

    // 2. Détection de l'OS
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS
      url = "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      // Android
      url = "market://details?id=" + androidPackage;
    }

    // 3. Appel serveur pour débloquer le badge (AJAX) si l'URL de l'API est fournie
    if (this.urlValue) {
        fetch(this.urlValue, {
          method: "POST",
          headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            "Content-Type": "application/json"
          }
        }).then(() => {
          this.redirectAndReload(url);
        }).catch(err => {
          console.error("Erreur serveur :", err);
          this.redirectAndReload(url);
        });
    } else {
        this.redirectAndReload(url);
    }
  }

  redirectAndReload(url) {
    if (url) {
      if (url.startsWith('http')) {
        // Open web link in a new tab so the user does not leave the site
        window.open(url, '_blank');
        window.location.reload();
      } else {
        // Custom app store URI schemes (itms-apps, market)
        window.location.href = url;
        // Reload after a short timeout so that the badge is updated when they return
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }
    } else {
      window.location.reload();
    }
  }
}
