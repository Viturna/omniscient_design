$(document).ready(function () {
  let lastScrollTop = 0; // Pour détecter la direction du scroll

  $(window).on('scroll', function () {
    const currentScroll = $(window).scrollTop();
    const threshold = 50; // Ajustez selon vos besoins

    if (currentScroll > threshold) {
      $('.header-show').addClass('small-height');
      $('.header-top').addClass('show-header-top');
      $('.hidden').addClass('hidden');
      $('.info-header-show').addClass('hidden');
      $('.text-show').addClass('margin-text-header');
    } else {
      $('.header-show').removeClass('small-height');
      $('.header-top').removeClass('show-header-top');
      $('.hidden').removeClass('hidden');
      $('.info-header-show').removeClass('hidden');
      $('.text-show').removeClass('margin-text-header');
    }

    // Stocke la position de scroll actuelle pour la prochaine comparaison
    lastScrollTop = currentScroll;
  });
});
