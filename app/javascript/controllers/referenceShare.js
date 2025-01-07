$(document).ready(function() {
  // Sélecteurs mis à jour
  const shareModal = document.getElementById('shareModal');
  const closeModal = document.getElementById('closePopup'); // Utilisez ID au lieu de classe
  const shareButton = document.getElementById('shareButton'); // Assurez-vous que ce bouton existe

  const shareX = document.getElementById('shareX');
  const shareMessages = document.getElementById('shareMessages');
  const shareEmail = document.getElementById('shareEmail');
  const shareWhatsApp = document.getElementById('shareWhatsApp');
  const shareFacebook = document.getElementById('shareFacebook');
  const copyLink = document.getElementById('copyLink');
  const shareLink = document.getElementById('shareLink');

  const urlToShare = window.location.href;
  const textToShare = 'Découvrez cette œuvre incroyable !';

  shareLink.value = urlToShare;

  // Ouvrir la modale
  if (shareButton) {
    shareButton.addEventListener('click', (event) => {
      event.preventDefault();
      shareModal.style.display = 'flex';
    });
  }

  // Fermer la modale
  if (closeModal) {
    closeModal.addEventListener('click', () => {
      shareModal.style.display = 'none';
    });
  }

  // Fermer la modale en cliquant à l'extérieur
  window.addEventListener('click', (event) => {
    if (event.target === shareModal) {
      shareModal.style.display = 'none';
    }
  });

  // Actions de partage
  if (shareX) {
    shareX.addEventListener('click', () => {
      window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(textToShare)}&url=${encodeURIComponent(urlToShare)}`, '_blank');
    });
  }

  if (shareMessages) {
    shareMessages.addEventListener('click', () => {
      window.open(`sms:?body=${encodeURIComponent(textToShare + ' ' + urlToShare)}`, '_self');
    });
  }

  if (shareEmail) {
    shareEmail.addEventListener('click', () => {
      window.open(`mailto:?subject=${encodeURIComponent('Découvrez cette œuvre !')}&body=${encodeURIComponent(textToShare + ' ' + urlToShare)}`, '_self');
    });
  }

  if (shareWhatsApp) {
    shareWhatsApp.addEventListener('click', () => {
      window.open(`https://wa.me/?text=${encodeURIComponent(textToShare + ' ' + urlToShare)}`, '_blank');
    });
  }

  if (shareFacebook) {
    shareFacebook.addEventListener('click', () => {
      window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(urlToShare)}`, '_blank');
    });
  }

  // Copier le lien
   if (copyLink) {
   copyLink.addEventListener('click', () => {
     const shareLink = document.createElement('textarea');
     shareLink.value = window.location.href;
     document.body.appendChild(shareLink);
     shareLink.select();
     document.execCommand('copy');
     document.body.removeChild(shareLink);
     alert('Lien copié dans le presse-papiers');
   });
 }
 });
