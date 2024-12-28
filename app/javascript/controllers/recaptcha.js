document.addEventListener('DOMContentLoaded', function() {
  const recaptchaSiteKey = document.querySelector('meta[name="recaptcha-site-key"]').getAttribute('content');

  document.querySelector("form").addEventListener("submit", function(event) {
    event.preventDefault(); // Empêche l'envoi temporaire pour attendre le token
    grecaptcha.execute(recaptchaSiteKey, {action: 'submit'}).then(function(token) {
      document.getElementById('recaptcha_token').value = token;
      event.target.submit(); // Soumet le formulaire après avoir obtenu le token
    });
  });
});
