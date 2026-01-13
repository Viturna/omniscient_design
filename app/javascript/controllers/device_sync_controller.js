import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="device-sync"
export default class extends Controller {
    connect() {
        // On tente la synchro dès que le contrôleur se connecte
        this.sync()
    }

    sync() {
        // 1. On vérifie si iOS a injecté le token
        if (window.FCMToken) {
            console.log("📱 Token iOS détecté, envoi au serveur...", window.FCMToken)
            this.sendToken(window.FCMToken)
        } else {
            console.log("⏳ Pas de token iOS détecté pour le moment.")
        }
    }

    sendToken(token) {
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

        fetch('/api/devices', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                token: token,
                platform: 'ios' // ou détecter via userAgent
            })
        })
            .then(response => {
                if (response.ok) {
                    console.log("✅ Device enregistré avec succès !")
                } else {
                    console.error("❌ Erreur lors de l'enregistrement du device")
                }
            })
            .catch(error => console.error("❌ Erreur réseau :", error))
    }
}