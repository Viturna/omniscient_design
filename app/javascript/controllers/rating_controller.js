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
        this.trigger();
      }, 100);
    }
  }

  trigger(event) {
    if (event) event.preventDefault();
    
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    
    // IDs officiels
    const iosAppId = "6754964970";
    const androidPackage = "com.thomasriq.omniscientdesign";

    // 1. Détecter si on est à l'intérieur d'une application hybride (WebView de l'App iOS/Android)
    const isWebview = !!(
      window.Capacitor || 
      window.cordova || 
      window.navigator.standalone || 
      userAgent.includes('wv') || 
      userAgent.includes('WebView') || 
      (/iPhone|iPad|iPod/.test(userAgent) && !userAgent.includes('Safari'))
    );

    let url = "";

    // 2. Sélectionner l'URL optimale. Les liens HTTPS officiels sont interceptés nativement
    // par iOS/Android, mais les WebViews nécessitent des protocoles spécifiques (itms-apps / market)
    // pour forcer la sortie de la WebView/In-app browser vers la boutique native.
    const useDeepLink = isWebview || this.redirectSelfValue;

    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS : Ouvre nativement l'application App Store
      url = useDeepLink 
        ? "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review"
        : "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      // Android : Ouvre nativement l'application Google Play Store
      url = useDeepLink
        ? "market://details?id=" + androidPackage
        : "https://play.google.com/store/apps/details?id=" + androidPackage;
    } else {
      // Desktop : Pas de redirection
      url = "";
    }

    // 3. Débloquer le badge en arrière-plan (fetch asynchrone sans bloquer le thread principal)
    if (this.urlValue) {
      fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Content-Type": "application/json"
        }
      }).catch(err => console.error("Erreur serveur :", err));
    }

    // 4. Redirection SYNCHRONE (essentiel pour ne pas être bloqué par le bloqueur de pub/popups des WebViews)
    if (url) {
      if (isWebview || this.redirectSelfValue) {
        // Les WebViews bloquent les popups (window.open). Utiliser location.href est 100% sûr,
        // et l'OS intercepte l'URL HTTPS pour ouvrir l'App Store/Play Store externe.
        window.location.href = url;
      } else {
        // Sur navigateur mobile classique : ouvre dans un nouvel onglet
        window.open(url, '_blank');
      }
    }

    // 5. Recharger la page après un court délai pour que le fetch d'attribution du badge ait le temps de se terminer
    setTimeout(() => {
      if (this.redirectSelfValue) {
        window.location.href = this.hasUrlValue ? "/mes-badges" : "/";
      } else {
        window.location.reload();
      }
    }, 800);
  }
}
