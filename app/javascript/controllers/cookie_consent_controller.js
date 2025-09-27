import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["banner"]

    connect() {
        document.addEventListener("turbo:load", () => this.init())
        const consent = localStorage.getItem("cookie-consent")

        if (!consent) {
            // Première visite → on affiche la bannière
            this.bannerTarget.style.display = "block"
        } else if (consent === "accepted") {
            // Déjà accepté → on active GA
            this.enableCookies()
        } else {
            // Déjà refusé → on ne montre pas la bannière
            this.bannerTarget.style.display = "none"
        }
    }


    accept() {
        localStorage.setItem("cookie-consent", "accepted")
        this.bannerTarget.style.display = "none"
        this.enableCookies()
    }

    decline() {
        localStorage.setItem("cookie-consent", "declined")
        this.bannerTarget.style.display = "none"
    }

    enableCookies() {
        if (document.getElementById("ga-script")) return;

        const script = document.createElement("script")
        script.id = "ga-script"
        script.src = "https://www.googletagmanager.com/gtag/js?id=G-WVD06EPJC3"
        script.async = true
        document.head.appendChild(script)

        script.onload = () => {
            window.dataLayer = window.dataLayer || []
            function gtag() { window.dataLayer.push(arguments) }
            gtag("js", new Date())
            gtag("config", "G-WVD06EPJC3")
        }
    }
}
