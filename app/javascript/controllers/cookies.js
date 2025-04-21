// Lorsque la page est chargée
document.addEventListener('DOMContentLoaded', function () {
    const consentBanner = document.getElementById('cookie-consent-banner');
    const acceptButton = document.getElementById('accept-cookies');
    const declineButton = document.getElementById('decline-cookies');

    // Vérifier si le consentement a déjà été donné (cookie existant)
    if (!localStorage.getItem('cookie-consent')) {
        consentBanner.style.display = 'block'; // Afficher le bandeau de consentement
    }

    // Lorsque l'utilisateur accepte les cookies
    acceptButton.onclick = function () {
        localStorage.setItem('cookie-consent', 'accepted'); // Enregistrer le consentement
        consentBanner.style.display = 'none'; // Cacher le bandeau
        enableCookies(); // Activer les cookies (ex. Google Analytics)
    };

    // Lorsque l'utilisateur refuse les cookies
    declineButton.onclick = function () {
        localStorage.setItem('cookie-consent', 'declined'); // Enregistrer le refus
        consentBanner.style.display = 'none'; // Cacher le bandeau
    };

    // Fonction pour activer les cookies (par exemple, Google Analytics)
    function enableCookies() {
        // Google Analytics
        let script = document.createElement('script');
        script.src = 'https://www.googletagmanager.com/gtag/js?id=G-WVD06EPJC3';
        script.async = true;
        script.setAttribute('data-cookie-consent', 'tracking');
        document.head.appendChild(script);

        script.onload = function () {
            window.dataLayer = window.dataLayer || [];
            function gtag() { dataLayer.push(arguments); }
            gtag('js', new Date());
            gtag('config', 'G-WVD06EPJC3');
        };
    }
});
