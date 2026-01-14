import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.sync()
        this.startPolling()
    }

    disconnect() {
        this.stopPolling()
    }

    startPolling() {
        this.interval = setInterval(() => {
            if (window.FCMToken) {
                this.sync()
                this.stopPolling()
            }
        }, 500)

        setTimeout(() => {
            this.stopPolling()
        }, 10000)
    }

    stopPolling() {
        if (this.interval) clearInterval(this.interval)
    }

    sync() {
        if (!window.FCMToken) return
        if (this.lastSentToken === window.FCMToken) return

        console.log("📱 Token iOS détecté, envoi au serveur...")
        this.lastSentToken = window.FCMToken

        const csrfElement = document.querySelector('meta[name="csrf-token"]')
        const csrfToken = csrfElement ? csrfElement.getAttribute('content') : ''

        fetch('/api/devices', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                token: window.FCMToken,
                platform: 'ios'
            })
        })
            .then(response => {
                if (response.ok) {
                    console.log("✅ Device enregistré avec succès !")
                } else {
                    console.error("❌ Erreur serveur lors de l'enregistrement")
                }
            })
            .catch(error => console.error("❌ Erreur réseau :", error))
    }
}