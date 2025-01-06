document.addEventListener('DOMContentLoaded', () => {
  const validation = document.getElementById('validation');
  const overlay = document.getElementById('overlay');
  const overlaybottom = document.getElementById('overlay-bottom');

  function hideValidation() {
    if (validation && overlay) {
      validation.style.display = 'none';
      overlay.style.display = 'none';
      window.removeEventListener('scroll', hideValidation);
    }
  }

  function seenValidation() {
    if (overlaybottom) {
      overlaybottom.style.display = 'block';
      window.removeEventListener('scroll', seenValidation);
    }
  }

  window.addEventListener('scroll', hideValidation);
  window.addEventListener('scroll', seenValidation);
});
