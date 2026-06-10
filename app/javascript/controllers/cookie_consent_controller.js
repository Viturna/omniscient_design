import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["banner"]

    connect() {
        const consent = localStorage.getItem("cookie-consent")

        if (consent === "accepted") {
            // Déjà accepté → on active GA
            this.enableCookies()
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
