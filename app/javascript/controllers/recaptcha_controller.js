import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["token"]

  connect() {
    this.initRecaptcha()
    this.loadScriptOnInteraction = this.loadScript.bind(this)
    this.element.addEventListener('mouseenter', this.loadScriptOnInteraction, { once: true })
    this.element.addEventListener('focusin', this.loadScriptOnInteraction, { once: true })
    this.element.addEventListener('touchstart', this.loadScriptOnInteraction, { once: true })
  }

  initRecaptcha() {
    const metaTag = document.querySelector('meta[name="recaptcha-site-key"]')
    if (!metaTag) {
      console.error("Meta tag recaptcha-site-key not found")
      return
    }
    this.siteKey = metaTag.getAttribute('content')

    // On s'assure de ne pas avoir de doublons d'écouteurs
    if (this.submitHandler) {
      this.element.removeEventListener("submit", this.submitHandler)
    }
    this.submitHandler = this.handleSubmit.bind(this)
    this.element.addEventListener("submit", this.submitHandler)
  }

  loadScript() {
    if (window.grecaptcha || document.querySelector('script[src*="recaptcha/api.js"]')) return;
    const script = document.createElement('script');
    script.src = `https://www.google.com/recaptcha/api.js?render=${this.siteKey}`;
    document.head.appendChild(script);
  }

  disconnect() {
    if (this.submitHandler) {
      this.element.removeEventListener("submit", this.submitHandler)
    }
    this.element.removeEventListener('mouseenter', this.loadScriptOnInteraction)
    this.element.removeEventListener('focusin', this.loadScriptOnInteraction)
    this.element.removeEventListener('touchstart', this.loadScriptOnInteraction)
  }

  handleSubmit(event) {
    // Si le token est déjà rempli, on laisse le formulaire se soumettre normalement
    if (this.tokenTarget.value) return

    // Sinon, on empêche la soumission et on lance reCAPTCHA
    event.preventDefault()
    event.stopImmediatePropagation()

    if (typeof grecaptcha === "undefined") {
      console.warn("reCAPTCHA pas encore chargé, attente...")
      this.loadScript()
      
      const checkInterval = setInterval(() => {
        if (typeof grecaptcha !== "undefined") {
          clearInterval(checkInterval)
          this.executeRecaptcha()
        }
      }, 100)
      
      // Fallback au bout de 3 secondes si reCAPTCHA ne se charge jamais
      setTimeout(() => {
        if (typeof grecaptcha === "undefined") {
          clearInterval(checkInterval)
          console.error("reCAPTCHA n'a pas pu être chargé (timeout).")
          this.forceTrixSync()
          this.element.submit()
        }
      }, 3000)
      return
    }

    this.executeRecaptcha()
  }

  executeRecaptcha() {
    let hasExecuted = false;
    
    const fallbackTimeout = setTimeout(() => {
      if (!hasExecuted) {
        console.warn("reCAPTCHA a mis trop de temps, soumission forcée !");
        hasExecuted = true;
        this.forceTrixSync();
        this.element.submit();
      }
    }, 4000);

    grecaptcha.ready(() => {
      grecaptcha.execute(this.siteKey, { action: 'submit' }).then((token) => {
        if (hasExecuted) return;
        hasExecuted = true;
        clearTimeout(fallbackTimeout);

        this.tokenTarget.value = token;
        
        // Forcer la synchro Trix AVANT de soumettre
        this.forceTrixSync();

        // Utiliser submit() directement car le token est déjà en place
        // requestSubmit() déclencherait un nouveau event "submit" → boucle infinie
        this.element.submit();
      }, (error) => {
        if (hasExecuted) return;
        hasExecuted = true;
        clearTimeout(fallbackTimeout);

        console.error("Erreur reCAPTCHA execution:", error)
        this.forceTrixSync();
        this.element.submit()
      })
    })
  }

  forceTrixSync() {
    this.element.querySelectorAll('trix-editor').forEach(editor => {
      const inputId = editor.getAttribute('input');
      if (!inputId) return;
      
      const inputElement = document.getElementById(inputId);
      if (!inputElement) return;

      // editor.value lit depuis le hidden input (qui peut être vide si Trix
      // n'a jamais synchro car il était dans display:none).
      // editor.innerHTML contient le VRAI contenu tapé par l'utilisateur.
      const content = editor.innerHTML;
      if (content && content.trim() !== "") {
        inputElement.value = content;
      }
    });
  }
}