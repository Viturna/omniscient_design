import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    autoTrigger: Boolean,
    redirectSelf: Boolean
  }

  connect() {
    if (this.autoTriggerValue) {
      setTimeout(() => {
        // En cas d'auto-déclenchement (au chargement), les navigateurs et WebViews
        // bloquent l'ouverture de nouvelles fenêtres (window.open) sans geste utilisateur.
        // On tente une redirection "best-effort" en modifiant window.location.href.
        // Si la WebView le bloque, l'utilisateur a toujours le bouton réel sur lequel cliquer.
        this.autoRedirect();
      }, 100);
    }
  }

  autoRedirect() {
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    const iosAppId = "6754964970";
    const androidPackage = "com.thomasriq.omniscientdesign";

    let url = "";
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      url = "https://play.google.com/store/apps/details?id=" + androidPackage;
    }

    if (url) {
      // 1. Tenter Capacitor Browser si disponible
      if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Browser) {
        try {
          window.Capacitor.Plugins.Browser.open({ url: url });
          return;
        } catch (e) {
          console.error("Erreur Capacitor Browser autoRedirect :", e);
        }
      }

      // 2. Redirection location.href
      window.location.href = url;
    }
  }

  trigger(event) {
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    const isMobile = /iPad|iPhone|iPod|android/i.test(userAgent);
    
    // Si c'est sur ordinateur (pas de redirection vers un store), on bloque le clic inutile
    if (!isMobile) {
      if (event) event.preventDefault();
      return;
    }

    // IMPORTANT : On ne fait PAS event.preventDefault() pour le clic utilisateur mobile !
    // Cela permet de préserver le geste utilisateur natif (User Gesture), garantissant
    // que la WebView laisse le lien s'ouvrir et lance le Store externe en quittant l'app.

    // Débloquer le badge en arrière-plan (fetch asynchrone sans bloquer le thread principal)
    if (this.urlValue) {
      fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Content-Type": "application/json"
        }
      }).catch(err => console.error("Erreur serveur :", err));
    }

    // Recharger la page ou rediriger après un court délai pour que le fetch d'attribution du badge ait le temps de se terminer
    setTimeout(() => {
      if (this.redirectSelfValue) {
        window.location.href = this.hasUrlValue ? "/mes-badges" : "/";
      } else {
        window.location.reload();
      }
    }, 800);
  }
}
