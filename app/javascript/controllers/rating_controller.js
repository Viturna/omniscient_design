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
    // Pour la redirection automatique au chargement, on utilise UNIQUEMENT des URLs HTTPS.
    // Les navigateurs mobiles classiques (Safari, Chrome) bloquent les redirections automatiques vers des protocoles custom (itms-apps / market).
    // De plus, les liens HTTPS officiels sont interceptés nativement par iOS/Android et par la SceneDelegate de notre WebView.
    if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
      url = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      url = "https://play.google.com/store/apps/details?id=" + androidPackage;
    }

    if (url) {
      let opened = false;
      // 1. Tenter le plugin Capacitor App.openUrl (si disponible)
      if (window.Capacitor && window.Capacitor.Plugins) {
        if (window.Capacitor.Plugins.App && window.Capacitor.Plugins.App.openUrl) {
          try {
            window.Capacitor.Plugins.App.openUrl({ url: url });
            opened = true;
          } catch (e) {
            console.error("Erreur Capacitor App autoRedirect :", e);
          }
        }
        // 2. Tenter le plugin Capacitor Browser
        if (!opened && window.Capacitor.Plugins.Browser && window.Capacitor.Plugins.Browser.open) {
          try {
            window.Capacitor.Plugins.Browser.open({ url: url });
            opened = true;
          } catch (e) {
            console.error("Erreur Capacitor Browser autoRedirect :", e);
          }
        }
      }

      // 3. Tenter Cordova InAppBrowser
      if (!opened && window.cordova && window.cordova.InAppBrowser) {
        try {
          window.cordova.InAppBrowser.open(url, '_system');
          opened = true;
        } catch (e) {
          console.error("Erreur Cordova InAppBrowser autoRedirect :", e);
        }
      }

      // 4. Redirection location.href (100% fonctionnel sur Safari/Chrome et intercepté par SceneDelegate.swift)
      if (!opened) {
        window.location.href = url;
      }

      // Débloquer le badge en arrière-plan
      if (this.urlValue) {
        fetch(this.urlValue, {
          method: "POST",
          headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            "Content-Type": "application/json"
          }
        }).catch(err => console.error("Erreur serveur :", err));
      }

      // Rediriger la page après un court délai pour ne pas rester bloqué sur le spinner
      setTimeout(() => {
        if (this.redirectSelfValue) {
          window.location.href = this.hasUrlValue ? "/mes-badges" : "/";
        } else {
          window.location.reload();
        }
      }, 800);
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
      storeUrl = "https://apps.apple.com/app/id" + iosAppId + "?action=write-review";
      deepLink = "itms-apps://itunes.apple.com/app/id" + iosAppId + "?action=write-review";
    } else if (/android/i.test(userAgent)) {
      storeUrl = "https://play.google.com/store/apps/details?id=" + androidPackage;
      deepLink = "market://details?id=" + androidPackage;
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
    } else if (storeUrl) {
      // Sur navigateur mobile classique : le geste utilisateur est présent !
      // On peut utiliser window.open(storeUrl, '_blank') de manière synchrone et sécurisée,
      // ce qui ouvre le Store proprement sans laisser l'utilisateur sur une page blanche.
      if (event) event.preventDefault();
      window.open(storeUrl, '_blank');
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

    // Recharger la page ou rediriger après un court délai pour que le badge ait le temps d'être attribué
    setTimeout(() => {
      if (this.redirectSelfValue) {
        window.location.href = this.hasUrlValue ? "/mes-badges" : "/";
      } else {
        window.location.reload();
      }
    }, 800);
  }
}

