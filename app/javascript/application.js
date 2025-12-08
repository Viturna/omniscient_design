// ------------------------
// IMPORTS
// ------------------------
import "@hotwired/turbo-rails"
import "controllers"
import "jquery_provider"
import "select2"
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
}

document.addEventListener("turbo:load", initLenis)