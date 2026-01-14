import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 800 },
        threshold: { type: Number, default: 50 }
    }
    // On ajoute les targets pour manipuler le DOM facilement
    static targets = ["container", "trigger"]

    connect() {
        console.log("🚀 [ScrollVertical] Connecté !")

        // DEBUG: Vérification des cibles
        if (this.hasContainerTarget) {
            console.log("✅ Target 'container' trouvée")
        } else {
            console.error("❌ Target 'container' MANQUANTE ! Vérifiez le HTML data-scroll-vertical-target='container'")
        }

        if (this.hasTriggerTarget) {
            console.log("✅ Target 'trigger' trouvée")
        } else {
            console.error("❌ Target 'trigger' MANQUANTE ! Vérifiez le HTML data-scroll-vertical-target='trigger'")
        }

        this.isScrolling = false
        this.isLoading = false

        this.handleWheel = this.handleWheel.bind(this)
        this.element.addEventListener("wheel", this.handleWheel, { passive: false })

        this.handleTouchStart = this.handleTouchStart.bind(this)
        this.handleTouchMove = this.handleTouchMove.bind(this)
        this.handleTouchEnd = this.handleTouchEnd.bind(this)

        this.element.addEventListener("touchstart", this.handleTouchStart, { passive: false })
        this.element.addEventListener("touchmove", this.handleTouchMove, { passive: false })
        this.element.addEventListener("touchend", this.handleTouchEnd)

        // LANCE LA VÉRIFICATION INITIALE
        console.log("⏱️ [ScrollVertical] Lancement checkAndFillScreen dans 200ms...")
        setTimeout(() => this.checkAndFillScreen(), 200)
    }

    disconnect() {
        console.log("👋 [ScrollVertical] Déconnecté")
        this.element.removeEventListener("wheel", this.handleWheel)
        this.element.removeEventListener("touchstart", this.handleTouchStart)
        this.element.removeEventListener("touchmove", this.handleTouchMove)
        this.element.removeEventListener("touchend", this.handleTouchEnd)
    }

    // --- LOGIQUE LOAD MORE ---

    checkAndFillScreen() {
        if (!this.hasTriggerTarget) {
            console.warn("⚠️ [CheckFill] Impossible de vérifier : Trigger manquant.")
            return
        }

        const container = this.element
        const scrollHeight = container.scrollHeight
        const clientHeight = container.clientHeight

        console.log(`📏 [CheckFill] Hauteur Totale (Scroll): ${scrollHeight}px | Hauteur Visible (Client): ${clientHeight}px`)

        // Si la hauteur totale est inférieure à la hauteur visible + une petite marge
        if (scrollHeight <= clientHeight + 100) {
            console.log("🟢 [CheckFill] L'écran n'est pas rempli -> LOAD MORE !")
            this.loadMore()
        } else {
            console.log("🔴 [CheckFill] L'écran est bien rempli, pas de chargement auto.")
        }
    }

    loadMore() {
        if (this.isLoading) {
            console.log("⏳ [LoadMore] Déjà en cours de chargement...")
            return
        }
        if (!this.hasTriggerTarget) return

        this.isLoading = true
        console.log("🚀 [LoadMore] Démarrage...")

        const trigger = this.triggerTarget
        // Si le trigger est caché (fin de liste atteinte), on arrête
        if (trigger.style.display === "none") {
            console.log("🛑 [LoadMore] Trigger caché (Fin de liste atteinte).")
            return
        }

        // Récupération des données depuis le HTML
        let offset = parseInt(trigger.dataset.offset) || 0
        let loadedIds = trigger.dataset.loadedIds || ''
        let itemsUntilNextAd = trigger.dataset.itemsUntilNextAd
        let adIndex = trigger.dataset.adIndex
        let adsOrder = trigger.dataset.adsOrder

        const url = `/oeuvres/load_more?offset=${offset}&loaded_ids=${loadedIds}&items_until_next_ad=${itemsUntilNextAd}&ad_index=${adIndex}&ads_order=${adsOrder}`

        console.log(`📡 [LoadMore] Fetch URL: ${url}`)

        fetch(url, {
            headers: { 'Accept': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                console.log("📥 [LoadMore] Réponse reçue")
                if (data.html.trim() === "") {
                    console.log("🏁 [LoadMore] HTML vide renvoyé. Fin de la pagination.")
                    trigger.style.display = "none"
                } else {
                    // Insertion dans le container cible (boxCard)
                    if (this.hasContainerTarget) {
                        console.log("📝 [LoadMore] Injection du HTML dans le container")
                        this.containerTarget.insertAdjacentHTML("beforeend", data.html)
                    } else {
                        console.error("❌ [LoadMore] Impossible d'injecter : Target 'container' manquante")
                    }

                    // Mise à jour des datas
                    trigger.dataset.itemsUntilNextAd = data.items_until_next_ad
                    trigger.dataset.adIndex = data.ad_index

                    const currentCards = Array.from(this.element.querySelectorAll('.card:not(.ad-card)'))
                    const allLoadedIds = currentCards.map(c => c.dataset.id).filter(id => id)

                    trigger.dataset.offset = allLoadedIds.length
                    trigger.dataset.loadedIds = allLoadedIds.join(',')

                    console.log(`📊 [LoadMore] Nouvel offset: ${allLoadedIds.length}`)
                    this.element.querySelectorAll(".card, .ad-card").forEach(c => c.style.marginBottom = "10px")

                    setTimeout(() => {
                        this.isLoading = false
                        console.log("🔄 [LoadMore] Vérification récursive de l'écran...")
                        this.checkAndFillScreen()
                    }, 100)
                }
            })
            .catch(err => {
                console.error("💥 [LoadMore] Erreur Fetch:", err)
                this.isLoading = false
            })
    }

    // --- NAVIGATION GESTURE ---

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

        if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
            if (deltaX > 0) {
                window.location.href = '/designers'
            }
            return
        }

        if (Math.abs(deltaY) > Math.abs(deltaX)) {
            if (Math.abs(deltaY) > this.thresholdValue) {
                this.triggerScroll(deltaY > 0 ? 1 : -1)
            }
        }
    }

    triggerScroll(direction) {
        this.isScrolling = true

        if (direction > 0) {
            this.scrollToNext()
        } else {
            this.scrollToPrev()
        }

        setTimeout(() => {
            this.isScrolling = false
        }, this.cooldownValue)
    }

    scrollToNext() {
        this.moveToCard(1)
    }

    scrollToPrev() {
        this.moveToCard(-1)
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

        if (targetIndex >= cards.length - 1) {
            console.log("👇 [Navigation] Atteint la dernière carte -> Appel LoadMore")
            this.loadMore()
        }

        if (targetIndex < 0) targetIndex = 0
        if (targetIndex >= cards.length) targetIndex = cards.length - 1

        const targetCard = cards[targetIndex]
        targetCard.scrollIntoView({ behavior: "smooth", block: "start" })
    }
}