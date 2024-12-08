$(document).ready(function() {
  $(window).on('scroll', function() {
    var currentScroll = $(window).scrollTop();

    if (currentScroll > 30) {
      $('.header-show').addClass('small-height');
      $('.header-top').addClass('show-header-top');
      $('.hidden').addClass('hidden');
      $('.info-header-show').addClass('hidden');
      $('.content-show').css('margin-top', '50vh'); // Ajuste la marge en fonction du scroll
    } else {
      $('.header-show').removeClass('small-height');
      $('.header-top').removeClass('show-header-top');
      $('.hidden').removeClass('hidden');
      $('.info-header-show').removeClass('hidden');
      $('.content-show').css('margin-top', '20px'); // Reviens à la valeur par défaut
    }
  });
});
