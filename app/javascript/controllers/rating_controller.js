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

    // 2. Sélectionner l'URL optimale. Les liens HTTPS officiels sont reconnus et sécurisés.
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      // iOS : URL de l'App Store
      url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      // Android : URL du Google Play Store
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

    // 4. Redirection SYNCHRONE
    if (url) {
      if (isWebview) {
        // 1. Si on est dans Capacitor avec le plugin Browser, l'utiliser pour ouvrir directement en externe
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Browser) {
          try {
            window.Capacitor.Plugins.Browser.open({ url: url });
            return;
          } catch (e) {
            console.error("Erreur Capacitor Browser :", e);
          }
        }

        // 2. Si on est dans Cordova avec InAppBrowser
        if (window.cordova && window.cordova.InAppBrowser) {
          try {
            window.cordova.InAppBrowser.open(url, '_system');
            return;
          } catch (e) {
            console.error("Erreur Cordova InAppBrowser :", e);
          }
        }

        // 3. Fallback universel : Simuler un clic physique sur un tag <a> avec target="_blank"
        // Les WebViews (iOS WKWebView, Android WebView) interceptent nativement 'target="_blank"'
        // pour ouvrir le lien HTTPS externe dans le navigateur système ou lancer l'application native (App Store/Play Store).
        const link = document.createElement('a');
        link.href = url;
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      } else if (this.redirectSelfValue) {
        // Redirection directe dans le même onglet pour les navigateurs mobiles classiques
        window.location.href = url;
      } else {
        // Sur navigateur mobile classique depuis la page des badges : ouvre dans un nouvel onglet
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
