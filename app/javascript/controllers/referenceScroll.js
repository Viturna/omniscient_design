document.addEventListener('DOMContentLoaded', function () {
  let lastScrollTop = 0; // Pour détecter la direction du scroll
  const scrollThreshold = 50; // Nombre de pixels à défiler avant de changer la taille du header

  window.addEventListener('scroll', function () {
    const currentScroll = window.pageYOffset || document.documentElement.scrollTop;
    const header = document.querySelector('.header-show');
    const text = document.querySelector('.text-show');
    const infos = document.querySelector('.header-top');
    const firstContent = this.document.querySelector('.info-card-first-content')

    if (currentScroll > lastScrollTop && currentScroll > scrollThreshold) {
      // Scroll vers le bas et dépasse le seuil
      firstContent.classList.add('hidden')
      infos.classList.add('show-header-top')
      header.classList.add('small-height');
      text.classList.add('small-height');
    } else if (currentScroll <= scrollThreshold) {
      // Scroll vers le haut et en dessous du seuil
      firstContent.classList.remove('hidden')
      infos.classList.remove('show-header-top')
      header.classList.remove('small-height');
      text.classList.remove('small-height');
    }

    lastScrollTop = currentScroll <= 0 ? 0 : currentScroll; // Pour éviter les valeurs négatives
  });
});
