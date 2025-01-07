$(document).ready(function () {
  const starRatings = document.querySelectorAll('.star-rating');
  starRatings.forEach(starRating => {
    const stars = starRating.querySelectorAll('label');
    const input = starRating.querySelector('input[type="hidden"]');
    stars.forEach(star => {
      star.addEventListener('click', function () {
        const value = this.getAttribute('data-value');
        input.value = value;
        updateStars(stars, value);
      });
    });
  });

  function updateStars(stars, value) {
    stars.forEach(star => {
      if (star.getAttribute('data-value') <= value) {
        star.style.color = '#f5c518';
      } else {
        star.style.color = '#ddd';
      }
    });
  }
});
