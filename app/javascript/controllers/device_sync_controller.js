import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { userId: Number }

    connect() {
        // Dès que la page s'affiche, on tente de synchroniser
        if (this.hasUserIdValue) {
            this.syncToken();
        }
    }

    syncToken() {
        // 1. Récupération du token envoyé par l'App Native
        // L'app iOS doit injecter le token dans window.FCMToken
        // Si vous utilisez une PWA pure, il faudra utiliser le SDK Firebase JS ici.
        const token = window.FCMToken;

        if (!token) {
            console.log("ℹ️ [Device Sync] Pas de token détecté (Navigateur classique ou Token non prêt)");
            return;
        }

        // 2. Envoi au serveur Rails
        fetch('/api/devices', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
            },
            body: JSON.stringify({ token: token, platform: 'ios' })
        })
            .then(response => {
                if (response.ok) console.log("✅ [Device Sync] Token envoyé au serveur avec succès !");
            });
    }
}