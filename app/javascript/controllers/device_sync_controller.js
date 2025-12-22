import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { userId: Number }

    connect() {
        // 🛑 STOP : Si pas d'ID utilisateur (pas connecté), on ne fait rien !
        if (!this.hasUserIdValue || this.userIdValue === 0) {
            console.log("⏸️ [Device Sync] Utilisateur non connecté, attente du login...");
            return;
        }

        // Sinon, on lance la synchro
        this.syncToken();
    }

    syncToken() {
        const token = window.FCMToken;

        if (!token) {
            console.log("ℹ️ [Device Sync] Pas de token détecté");
            return;
        }

        console.log("🚀 [Device Sync] Envoi du token pour User ID:", this.userIdValue);

        fetch('/api/devices', {
            method: 'POST',
            credentials: 'include', // Important pour envoyer le cookie de session
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
            },
            body: JSON.stringify({ token: token, platform: 'ios' })
        })
            .then(response => {
                if (response.ok) {
                    console.log("✅ [Device Sync] Token synchronisé !");
                } else {
                    console.error("❌ [Device Sync] Erreur serveur :", response.status);
                }
            });
    }
}