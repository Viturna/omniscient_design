import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 500 },
        threshold: { type: Number, default: 50 }
    }
    static targets = ["container", "trigger"]

    connect() {
        console.log("🚀 [ScrollVertical] Connecté avec gestion Clavier & LoadMore agressif")
        this.isScrolling = false
        this.isLoading = false

        // BINDINGS
        this.handleWheel = this.handleWheel.bind(this)
        this.handleKeydown = this.handleKeydown.bind(this)
        this.handleTouchStart = this.handleTouchStart.bind(this)
        this.handleTouchMove = this.handleTouchMove.bind(this)
        this.handleTouchEnd = this.handleTouchEnd.bind(this)

        // LISTENERS
        this.element.addEventListener("wheel", this.handleWheel, { passive: false })
        document.addEventListener("keydown", this.handleKeydown) // Écoute globale du clavier

        this.element.addEventListener("touchstart", this.handleTouchStart, { passive: false })
        this.element.addEventListener("touchmove", this.handleTouchMove, { passive: false })
        this.element.addEventListener("touchend", this.handleTouchEnd)

        // Vérification initiale après rendu
        setTimeout(() => this.checkAndFillScreen(), 200)
    }

    disconnect() {
        this.element.removeEventListener("wheel", this.handleWheel)
        document.removeEventListener("keydown", this.handleKeydown)
        this.element.removeEventListener("touchstart", this.handleTouchStart)
        this.element.removeEventListener("touchmove", this.handleTouchMove)
        this.element.removeEventListener("touchend", this.handleTouchEnd)
    }

    // --- ACTIONS BOUTONS HTML ---
    scrollUp(event) {
        if (event) event.preventDefault()
        this.triggerScroll(-1)
    }

    scrollDown(event) {
        if (event) event.preventDefault()
        this.triggerScroll(1)
    }

    // --- GESTION CLAVIER ---
    handleKeydown(event) {
        // Ignore si on écrit dans un champ texte
        if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return

        if (event.key === "ArrowUp") {
            event.preventDefault()
            this.triggerScroll(-1)
        } else if (event.key === "ArrowDown") {
            event.preventDefault()
            this.triggerScroll(1)
        }
    }

    // --- LOAD MORE ---
    checkAndFillScreen() {
        if (!this.hasTriggerTarget) return

        const container = this.element
        // Si l'écran n'est pas rempli, on charge la suite
        if (container.scrollHeight <= container.clientHeight + 100) {
            console.log("🟢 [CheckFill] Ecran vide -> Chargement auto")
            this.loadMore()
        }
    }

    loadMore() {
        if (this.isLoading || !this.hasTriggerTarget) return
        this.isLoading = true

        const trigger = this.triggerTarget
        // Si le trigger est masqué, c'est qu'il n'y a plus rien en DB
        if (trigger.style.display === "none") return

        let offset = parseInt(trigger.dataset.offset) || 0
        let loadedIds = trigger.dataset.loadedIds || ''

        // Gestion des IDs spécifiques pour Designers/Studios (page Designers)
        // Ou fallback sur loadedIds générique (page Oeuvres)
        let loadedDesignerIds = trigger.dataset.loadedDesignerIds || ''
        let loadedStudioIds = trigger.dataset.loadedStudioIds || ''

        let itemsUntilNextAd = trigger.dataset.itemsUntilNextAd
        let adIndex = trigger.dataset.adIndex
        let adsOrder = trigger.dataset.adsOrder

        // Construction dynamique de l'URL selon la page (Oeuvres ou Designers)
        let baseUrl = window.location.pathname.includes("designers") ? "/designers/load_more" : "/oeuvres/load_more"

        // Construction des paramètres
        let params = new URLSearchParams({
            offset: offset,
            items_until_next_ad: itemsUntilNextAd,
            ad_index: adIndex,
            ads_order: adsOrder
        })

        if (loadedIds) params.append("loaded_ids", loadedIds)
        if (loadedDesignerIds) params.append("loaded_designer_ids", loadedDesignerIds)
        if (loadedStudioIds) params.append("loaded_studio_ids", loadedStudioIds)

        const url = `${baseUrl}?${params.toString()}`
        console.log(`📡 [LoadMore] Appel: ${url}`)

        fetch(url, { headers: { 'Accept': 'application/json' } })
            .then(response => response.json())
            .then(data => {
                if (data.html.trim() === "") {
                    console.log("🏁 [LoadMore] Fin de liste atteinte")
                    trigger.style.display = "none"
                } else {
                    if (this.hasContainerTarget) {
                        this.containerTarget.insertAdjacentHTML("beforeend", data.html)
                    }

                    // Mise à jour des datasets
                    trigger.dataset.itemsUntilNextAd = data.items_until_next_ad
                    trigger.dataset.adIndex = data.ad_index

                    // Mise à jour des IDs (Logique unifiée)
                    if (window.location.pathname.includes("designers")) {
                        // Logique Designers
                        const designerWrappers = Array.from(this.element.querySelectorAll('.entity-wrapper[data-entity-type="designer"]'))
                        const studioWrappers = Array.from(this.element.querySelectorAll('.entity-wrapper[data-entity-type="studio"]'))

                        const allLoadedDesignerIds = designerWrappers.map(el => el.dataset.id).filter(id => id)
                        const allLoadedStudioIds = studioWrappers.map(el => el.dataset.id).filter(id => id)

                        trigger.dataset.offset = allLoadedDesignerIds.length + allLoadedStudioIds.length
                        trigger.dataset.loadedDesignerIds = allLoadedDesignerIds.join(',')
                        trigger.dataset.loadedStudioIds = allLoadedStudioIds.join(',')
                    } else {
                        // Logique Oeuvres
                        const currentCards = Array.from(this.element.querySelectorAll('.card:not(.ad-card)'))
                        const allLoadedIds = currentCards.map(c => c.dataset.id).filter(id => id)

                        trigger.dataset.offset = allLoadedIds.length
                        trigger.dataset.loadedIds = allLoadedIds.join(',')
                    }

                    // Réalignement CSS
                    this.element.querySelectorAll(".card, .ad-card").forEach(c => c.style.marginBottom = "10px")

                    // Récursivité si écran géant
                    setTimeout(() => {
                        this.isLoading = false
                        this.checkAndFillScreen()
                    }, 100)
                }
            })
            .catch(err => {
                console.error("💥 [LoadMore] Erreur:", err)
                this.isLoading = false
            })
    }

    // --- NAVIGATION ---
    handleWheel(event) {
        event.preventDefault()
        if (this.isScrolling) return
        const deltaY = event.deltaY
        if (Math.abs(deltaY) < 20) return
        this.triggerScroll(deltaY > 0 ? 1 : -1)
    }

    handleTouchStart(event) {
        this.touchStartY = event.touches[0].clientY
        this.touchStartX = event.touches[0].clientX
    }

    handleTouchMove(event) {
        if (event.cancelable) event.preventDefault()
    }

    handleTouchEnd(event) {
        if (this.isScrolling) return
        const touchEndY = event.changedTouches[0].clientY
        const touchEndX = event.changedTouches[0].clientX
        const deltaY = this.touchStartY - touchEndY
        const deltaX = this.touchStartX - touchEndX

        // Swipe horizontal (changement page)
        if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
            // Swipe Droite -> Gauche (aller à droite)
            if (deltaX > 0 && window.location.pathname === '/') window.location.href = '/designers'
            // Swipe Gauche -> Droite (aller à gauche)
            if (deltaX < 0 && window.location.pathname.includes('designers')) window.location.href = '/oeuvres'
            return
        }

        // Swipe vertical
        if (Math.abs(deltaY) > Math.abs(deltaX)) {
            if (Math.abs(deltaY) > this.thresholdValue) {
                this.triggerScroll(deltaY > 0 ? 1 : -1)
            }
        }
    }

    triggerScroll(direction) {
        if (this.isScrolling) return
        this.isScrolling = true
        this.moveToCard(direction)
        setTimeout(() => { this.isScrolling = false }, this.cooldownValue)
    }

    moveToCard(direction) {
        const cards = Array.from(this.element.querySelectorAll(".card, .ad-card"))
        if (cards.length === 0) return

        const container = this.element
        const viewCenter = container.scrollTop + (container.clientHeight / 2)

        let currentIndex = cards.findIndex(card => {
            const cardTop = card.offsetTop
            const cardBottom = cardTop + card.offsetHeight
            return cardTop <= viewCenter && cardBottom >= viewCenter
        })

        if (currentIndex === -1) currentIndex = 0

        let targetIndex = currentIndex + direction

        // --- C'EST ICI QUE CA SE JOUE ---
        // 1. Si on vise l'avant-dernière carte ou plus loin -> Charger
        const nearEnd = targetIndex >= cards.length - 2
        // 2. Si on est DÉJÀ sur la dernière et qu'on essaie de descendre -> Charger
        const atEndTryingToDescend = (currentIndex === cards.length - 1) && (direction === 1)

        if (nearEnd || atEndTryingToDescend) {
            console.log("👇 [Navigation] Fin atteinte ou proche -> Appel LoadMore")
            this.loadMore()
        }

        // Limites pour le scroll visuel
        if (targetIndex < 0) targetIndex = 0
        if (targetIndex >= cards.length) targetIndex = cards.length - 1

        const targetCard = cards[targetIndex]
        targetCard.scrollIntoView({ behavior: "smooth", block: "start" })
    }
}