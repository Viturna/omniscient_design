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
    // par iOS/Android pour ouvrir directement l'App Store / Play Store sans planter de WebView.
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS : Ouvre nativement l'application App Store
      url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      // Android : Ouvre nativement l'application Google Play Store
      url = "https://play.google.com/store/apps/details?id=" + androidPackage;
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
      if (isWebview) {
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
      window.location.reload();
    }, 800);
  }
}
