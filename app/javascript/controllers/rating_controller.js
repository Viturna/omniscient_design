import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  trigger(event) {
    event.preventDefault();
    
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    
    // IDs officiels
    const iosAppId = "6754964970";
    const androidPackage = "com.thomasriq.omniscientdesign";

    let url = "";

    // Sélectionner l'URL optimale. Les liens HTTPS officiels sont interceptés nativement
    // par iOS/Android pour ouvrir directement l'App Store / Play Store sans planter de WebView.
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS : Ouvre nativement l'application App Store
      url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      // Android : Ouvre nativement l'application Google Play Store
      url = "https://play.google.com/store/apps/details?id=" + androidPackage;
    } else {
      // Desktop : Recherche Google de repli
      url = "https://www.google.com/search?q=Omniscient+Design";
    }

    // Appel serveur pour débloquer le badge
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
      if (url.includes('google.com/search')) {
        // Sur ordinateur (Desktop) : ouvre le lien de recherche dans un nouvel onglet
        window.open(url, '_blank');
        window.location.reload();
      } else {
        // Sur mobile (Web & App WebView) : location.href avec l'URL HTTPS officielle lance directement
        // l'App Store ou le Google Play Store natif du téléphone de l'utilisateur.
        window.location.href = url;
        // On recharge la page après 1.2 seconde afin que le badge apparaisse débloqué
        setTimeout(() => {
          window.location.reload();
        }, 1200);
      }
    } else {
      window.location.reload();
    }
  }
}
