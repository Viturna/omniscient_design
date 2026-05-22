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
        // Pour les WebViews/In-App Browsers : Utiliser window.open avec '_system' ou '_blank' 
        // ou simuler un vrai clic utilisateur sur un élément <a> avec target="_system".
        // Cela force le wrapper natif de l'application à ouvrir l'URL HTTPS dans le navigateur système / store externe.
        let opened = false;
        try {
          const win = window.open(url, '_system');
          if (win) opened = true;
        } catch (e) {
          console.error("Échec _system :", e);
        }

        if (!opened) {
          try {
            const win = window.open(url, '_blank');
            if (win) opened = true;
          } catch (e) {
            console.error("Échec _blank :", e);
          }
        }

        if (!opened) {
          const link = document.createElement('a');
          link.href = url;
          link.target = '_system';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        }
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
