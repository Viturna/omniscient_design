import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="device-sync"
export default class extends Controller {
    connect() {
        // 1. Essai immédiat
        this.sync()

        // 2. On lance une surveillance (polling) au cas où le token arrive après le chargement
        this.startPolling()
    }

    disconnect() {
        this.stopPolling()
    }

    startPolling() {
        // Vérifie toutes les 500ms
        this.interval = setInterval(() => {
            if (window.FCMToken) {
                // Dès qu'on le trouve, on envoie et on arrête de chercher
                this.sync()
                this.stopPolling()
            }
        }, 500)

        // Sécurité : on arrête de chercher après 10 secondes pour ne pas tourner dans le vide
        setTimeout(() => {
            this.stopPolling()
        }, 10000)
    }

    stopPolling() {
        if (this.interval) clearInterval(this.interval)
    }

    sync() {
        // S'il n'y a pas de token, on ne fait rien
        if (!window.FCMToken) return

        // Évite d'envoyer le même token plusieurs fois d'affilée
        if (this.lastSentToken === window.FCMToken) return

        console.log("📱 Token iOS détecté, envoi au serveur...")
        this.lastSentToken = window.FCMToken

        // Récupération sécurisée du CSRF Token
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