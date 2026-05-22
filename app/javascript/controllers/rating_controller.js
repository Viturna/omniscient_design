import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  trigger(event) {
    event.preventDefault();
    
    const userAgent = navigator.userAgent || navigator.vendor || window.opera;
    
    // IDs
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

    // 2. Sélectionner l'URL optimale de notation
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS
      if (isWebview) {
        // Les liens HTTPS standards sont plus sûrs dans les WebViews et s'ouvrent via _system
        url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
      } else {
        url = "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review";
      }
    } else if (/android/i.test(userAgent)) {
      // Android
      if (isWebview) {
        url = "https://play.google.com/store/apps/details?id=" + androidPackage;
      } else {
        url = "market://details?id=" + androidPackage;
      }
    } else {
      // Bureau (Desktop)
      url = "https://www.google.com/search?q=Omniscient+Design";
    }

    // 3. Appel serveur pour débloquer le badge
    if (this.urlValue) {
        fetch(this.urlValue, {
          method: "POST",
          headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            "Content-Type": "application/json"
          }
        }).then(() => {
          this.redirectAndReload(url, isWebview);
        }).catch(err => {
          console.error("Erreur serveur :", err);
          this.redirectAndReload(url, isWebview);
        });
    } else {
        this.redirectAndReload(url, isWebview);
    }
  }

  redirectAndReload(url, isWebview) {
    if (url) {
      if (isWebview) {
        // Dans une application hybride, _system force le système à ouvrir le navigateur externe natif du téléphone
        // évitant l'erreur "pas de connexion internet" ou "protocole non supporté" de la WebView
        window.open(url, '_system');
        window.location.reload();
      } else if (url.startsWith('http')) {
        // Navigateur Bureau / Mobile classique
        window.open(url, '_blank');
        window.location.reload();
      } else {
        // Redirection profonde (Deep link) pour les stores natifs en dehors des WebViews
        window.location.href = url;
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }
    } else {
      window.location.reload();
    }
  }
}
