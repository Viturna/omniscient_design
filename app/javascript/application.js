// ------------------------
// IMPORTS
// ------------------------
import "@hotwired/turbo-rails"
import "controllers"
import "jquery_provider"
import "select2"
import "trix"
import Lenis from "lenis"
window.gtag = window.gtag || function(){ (window.dataLayer = window.dataLayer || []).push(arguments); };
// ------------------------
// GESTION DU TOKEN PUSH (iOS & Android)
// ------------------------
window.registerDeviceToken = function (token, platform) {
    console.log(`📱 [JS] Réception du token ${platform} :`, token);

    const csrfToken = document.querySelector("[name='csrf-token']")?.content;

    if (!csrfToken) {
        console.error("❌ [JS] Erreur : Impossible de trouver le token CSRF");
        return;
    }

    fetch('/api/devices', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ token: token, platform: platform })
    })
        .then(response => {
            if (response.ok) {
                console.log("✅ [JS] Token enregistré avec succès sur le serveur !");
                localStorage.setItem('device_token', token);
            } else {
                console.error("❌ [JS] Erreur serveur lors de l'enregistrement :", response.status);
            }
        })
        .catch(error => {
            console.error("❌ [JS] Erreur réseau :", error);
        });
}


//  Initialisation de Lenis

let lenis;

function initLenis() {
    if (document.body.classList.contains('no-scroll')) {
        if (lenis) {
            lenis.destroy();
            lenis = null;
        }
        return;
    }

    if (!lenis) {
        lenis = new Lenis({
            duration: 1.1,
            easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
            direction: 'vertical',
            gestureDirection: 'vertical',
            smooth: true,
            mouseMultiplier: 1,
            smoothTouch: false,
            touchMultiplier: 2,
        })

        function raf(time) {
            if (lenis) {
                lenis.raf(time)
                requestAnimationFrame(raf)
            }
        }
        requestAnimationFrame(raf)
    }

    lenis.scrollTo(0, { immediate: true });
}

document.addEventListener("turbo:load", initLenis)
document.addEventListener("trix-initialize", function(event) {
  if (event.target.toolbarElement) {
    const dialogInputs = event.target.toolbarElement.querySelectorAll("input[required]");
    dialogInputs.forEach(input => input.removeAttribute("required"));
  }
});

// SÉCURITÉ TRIX : synchro forcée du contenu vers le hidden input à chaque changement
document.addEventListener("trix-change", function(event) {
  const editor = event.target;
  const inputId = editor.getAttribute("input");
  if (inputId) {
    const hiddenInput = document.getElementById(inputId);
    if (hiddenInput) {
      // innerHTML = le vrai contenu tapé, editor.value = lit le hidden input (circulaire)
      hiddenInput.value = editor.innerHTML;
    }
  }
});

// SÉCURITÉ TRIX : synchro finale avant soumission du formulaire
document.addEventListener("submit", function(event) {
  const form = event.target;
  if (!form || form.tagName !== "FORM") return;
  
  form.querySelectorAll("trix-editor").forEach(function(editor) {
    const inputId = editor.getAttribute("input");
    if (inputId) {
      const hiddenInput = document.getElementById(inputId);
      if (hiddenInput) {
        const content = editor.innerHTML;
        if (content && content.trim() !== "") {
          hiddenInput.value = content;
        }
      }
    }
  });
});
