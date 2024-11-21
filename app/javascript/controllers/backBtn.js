document.getElementById('back-btn').addEventListener('click', function() {
  const referrer = document.referrer;

  if (referrer && referrer.includes(window.location.hostname)) {
    window.history.back();
  } else {
    window.location.href = 'https://omniscientdesign.fr';
  }
});
