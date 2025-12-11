// app/javascript/controllers/image_modal_slider_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { imageCount: Number }

    connect() {
        this.modal = this.element;

        this.modal.setAttribute('aria-hidden', 'true');

        this.modal.addEventListener('slide:changed', this.updateCredits.bind(this));

        // Attacher l'écouteur d'événement pour le déclencheur d'ouverture
        document.querySelectorAll('.image-modal-trigger').forEach(el => {
            // Assurez-vous que le déclencheur dans le HTML utilise data-action="click->image-modal-slider#openModal"
            el.addEventListener('click', this.openModal.bind(this));
        });
    }

    disconnect() {
        this.modal.removeEventListener('slide:changed', this.updateCredits.bind(this));
        document.querySelectorAll('.image-modal-trigger').forEach(el => {
            el.removeEventListener('click', this.openModal.bind(this));
        });
    }

    openModal(event) {
        if (event) {
            event.preventDefault();
        }
        const activeSlideHeader = document.querySelector('.header-show .slider-slides .top-img-header.active');
        let initialIndex = 0;
        if (activeSlideHeader) {
            const allSlidesHeader = document.querySelectorAll('.header-show .slider-slides .top-img-header');
            allSlidesHeader.forEach((slide, index) => {
                if (slide === activeSlideHeader) {
                    initialIndex = index;
                }
            });
        }

        // 1. Afficher la modale et gérer l'ARIA (Résout le problème de focus/ARIA)
        this.modal.classList.add('show');
        this.modal.style.display = 'flex';
        document.body.classList.add('modal-open');
        this.modal.setAttribute('aria-hidden', 'false');


        // 2. Forcer la synchronisation du slider de la modale
        this.syncSlider(initialIndex);
    }

    closeModal() {
        this.modal.classList.remove('show');
        this.modal.style.display = 'none';
        document.body.classList.remove('modal-open');
        this.modal.setAttribute('aria-hidden', 'true');
    }

    syncSlider(index) {
        const sliderElement = this.modal.querySelector('[data-controller="slider"]');

        // Étape cruciale : Redémarrer le contrôleur pour forcer l'initialisation dans le DOM visible
        this.application.stop(sliderElement);
        this.application.start(sliderElement);

        const sliderController = this.application.getControllerForElementAndIdentifier(
            sliderElement, 'slider'
        );

        if (sliderController) {
            // Définir l'index et forcer le recalcul
            sliderController.indexValue = index;

            // Utiliser setTimeout pour s'assurer que le navigateur a fini de dessiner la modale
            setTimeout(() => {
                sliderController.recalculate();
            }, 50); // Délai augmenté pour plus de fiabilité
        }
    }

    updateCredits(event) {
        const newIndex = event.detail.index;
        const credits = this.modal.querySelectorAll('.image-credit');

        credits.forEach((credit, index) => {
            credit.style.display = index === newIndex ? 'block' : 'none';
            credit.classList.toggle('active-credit', index === newIndex);
        });
    }
}