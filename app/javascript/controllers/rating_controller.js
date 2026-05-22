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
        // LE POINT CLÉ : '_system' indique au wrapper mobile (Capacitor/Cordova/WKWebView) 
        // de sortir complètement de l'application pour lancer l'application externe du téléphone.
        // Cela va ouvrir directement la VRAIE application App Store ou Google Play Store.
        window.open(url, '_system');
        window.location.reload();
      } else if (url.includes('google.com/search')) {
        // Sur ordinateur (Desktop) : ouvre le lien de recherche dans un nouvel onglet
        window.open(url, '_blank');
        window.location.reload();
      } else {
        // Sur mobile classique (Web hors application) : on ouvre dans un nouvel onglet
        window.open(url, '_blank');
        window.location.reload();
      }
    } else {
      window.location.reload();
    }
  }
}
