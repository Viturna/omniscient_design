// ------------------------
// IMPORTS
// ------------------------
import "@hotwired/turbo-rails"

import "controllers"

// jQuery et plugins
import "jquery_provider"

import "select2"

window.registerDeviceToken = function (token, platform) {
    // On vérifie si on a déjà envoyé ce token pour ne pas spammer
    if (localStorage.getItem('device_token') === token) return;

    fetch('/api/devices', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ token: token, platform: platform })
    }).then(() => {
        localStorage.setItem('device_token', token); // On note qu'on l'a envoyé
    });
}