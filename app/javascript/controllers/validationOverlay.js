const validation = document.getElementById('validation');
const overlay = document.getElementById('overlay');

function hideValidation() {
  validation.style.display = 'none';
  overlay.style.display = 'none';
  window.removeEventListener('scroll', hideValidation);
}

window.addEventListener('scroll', hideValidation);


const overlaybottom = document.getElementById('overlay-bottom');

function seenValidation() {
  overlaybottom.style.display = 'block';
  window.removeEventListener('scroll', seenValidation);
}

window.addEventListener('scroll', seenValidation);
