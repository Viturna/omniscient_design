// ------------------------
// IMPORTS
// ------------------------
import "@hotwired/turbo-rails"

import "controllers"

// jQuery et plugins
import "jquery"
window.$ = window.jQuery = window.$ || window.jQuery

import "select2"

import "gsap"
import "gsap/ScrollTrigger"

document.addEventListener("turbo:load", function () {
    // Supprime les anciens iframes Adsense s'ils existent (prévention des doublons)
    document.querySelectorAll("ins.adsbygoogle").forEach(function (ad) {
        const iframe = ad.querySelector("iframe");
        if (iframe) {
            ad.innerHTML = ""; // Nettoie le conteneur
        }
    });

    // Réinitialise seulement les nouvelles pubs
    document.querySelectorAll("ins.adsbygoogle:not([data-adsbygoogle-status])").forEach(function (ad) {
        try {
            (adsbygoogle = window.adsbygoogle || []).push({});
        } catch (e) {
            console.warn("Adsense reload error:", e);
        }
    });
});
