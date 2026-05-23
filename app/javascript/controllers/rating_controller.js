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
      url = "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      url = "market://details?id=" + androidPackage;
    }

    if (url) {
      // 1. Tenter le plugin Capacitor App.openUrl (inclus par défaut dans le core)
      if (window.Capacitor && window.Capacitor.Plugins) {
        if (window.Capacitor.Plugins.App && window.Capacitor.Plugins.App.openUrl) {
          try {
            window.Capacitor.Plugins.App.openUrl({ url: url });
            return;
          } catch (e) {
            console.error("Erreur Capacitor App autoRedirect :", e);
          }
        }
        // 2. Tenter le plugin Capacitor Browser
        if (window.Capacitor.Plugins.Browser && window.Capacitor.Plugins.Browser.open) {
          try {
            window.Capacitor.Plugins.Browser.open({ url: url });
            return;
          } catch (e) {
            console.error("Erreur Capacitor Browser autoRedirect :", e);
          }
        }
      }

      // 3. Tenter Cordova InAppBrowser
      if (window.cordova && window.cordova.InAppBrowser) {
        try {
          window.cordova.InAppBrowser.open(url, '_system');
          return;
        } catch (e) {
          console.error("Erreur Cordova InAppBrowser autoRedirect :", e);
        }
      }

      // 4. Redirection location.href
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

    const iosAppId = "6754964970";
    const androidPackage = "com.thomasriq.omniscientdesign";

    let storeUrl = "";
    let deepLink = "";
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      storeUrl = "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review";
      deepLink = storeUrl;
    } else if (/android/i.test(userAgent)) {
      storeUrl = "market://details?id=" + androidPackage;
      deepLink = storeUrl;
    }

    // Détecter si on est à l'intérieur d'une application hybride (WebView de l'App iOS/Android)
    const isWebview = !!(
      window.Capacitor || 
      window.cordova || 
      window.navigator.standalone || 
      userAgent.includes('wv') || 
      userAgent.includes('WebView') || 
      (/iPhone|iPad|iPod/.test(userAgent) && !userAgent.includes('Safari'))
    );

    let openedExternally = false;

    if (isWebview && storeUrl) {
      // 1. Tenter le plugin Capacitor App.openUrl (inclus par défaut dans le core)
      if (window.Capacitor && window.Capacitor.Plugins) {
        if (window.Capacitor.Plugins.App && window.Capacitor.Plugins.App.openUrl) {
          try {
            window.Capacitor.Plugins.App.openUrl({ url: storeUrl });
            openedExternally = true;
          } catch (e) {
            console.error("Capacitor App.openUrl error:", e);
          }
        }
        
        // 2. Tenter le plugin Capacitor Browser
        if (!openedExternally && window.Capacitor.Plugins.Browser && window.Capacitor.Plugins.Browser.open) {
          try {
            window.Capacitor.Plugins.Browser.open({ url: storeUrl });
            openedExternally = true;
          } catch (e) {
            console.error("Capacitor Browser.open error:", e);
          }
        }
      }

      // 3. Tenter Cordova InAppBrowser
      if (!openedExternally && window.cordova && window.cordova.InAppBrowser) {
        try {
          window.cordova.InAppBrowser.open(storeUrl, '_system');
          openedExternally = true;
        } catch (e) {
          console.error("Cordova InAppBrowser error:", e);
        }
      }

      // 4. Si ouvert par plugin natif, on empêche le comportement par défaut de l'ancre HTML
      if (openedExternally) {
        if (event) event.preventDefault();
      } else {
        // Fallback ultime pour WebView basique : on tente de forcer via le protocole profond (itms-apps / market)
        // et on empêche le comportement par défaut pour éviter le chargement de la page HTTPS en interne.
        if (event) event.preventDefault();
        window.location.href = deepLink;
      }
    }

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
