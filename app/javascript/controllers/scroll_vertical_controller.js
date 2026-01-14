import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 500 }, // Reduced to 500ms for responsiveness
        threshold: { type: Number, default: 50 }
    }
    static targets = ["container", "trigger"]

    connect() {
        console.log("🚀 [ScrollVertical] Connecté !")
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

        setTimeout(() => this.checkAndFillScreen(), 200)
    }

    disconnect() {
        this.element.removeEventListener("wheel", this.handleWheel)
        this.element.removeEventListener("touchstart", this.handleTouchStart)
        this.element.removeEventListener("touchmove", this.handleTouchMove)
        this.element.removeEventListener("touchend", this.handleTouchEnd)
    }

    checkAndFillScreen() {
        if (!this.hasTriggerTarget) return

        const container = this.element
        console.log(`📏 [CheckFill] ScrollHeight: ${container.scrollHeight} | ClientHeight: ${container.clientHeight}`)

        if (container.scrollHeight <= container.clientHeight + 100) {
            console.log("🟢 [CheckFill] Ecran vide -> LoadMore")
            this.loadMore()
        }
    }

    loadMore() {
        if (this.isLoading || !this.hasTriggerTarget) return
        this.isLoading = true

        const trigger = this.triggerTarget
        if (trigger.style.display === "none") return

        let offset = parseInt(trigger.dataset.offset) || 0
        let loadedIds = trigger.dataset.loadedIds || ''
        let itemsUntilNextAd = trigger.dataset.itemsUntilNextAd
        let adIndex = trigger.dataset.adIndex
        let adsOrder = trigger.dataset.adsOrder

        const url = `/oeuvres/load_more?offset=${offset}&loaded_ids=${loadedIds}&items_until_next_ad=${itemsUntilNextAd}&ad_index=${adIndex}&ads_order=${adsOrder}`
        console.log(`📡 [LoadMore] Calling: ${url}`)

        fetch(url, { headers: { 'Accept': 'application/json' } })
            .then(response => response.json())
            .then(data => {
                if (data.html.trim() === "") {
                    console.log("🏁 [LoadMore] Fin de liste")
                    trigger.style.display = "none"
                } else {
                    if (this.hasContainerTarget) {
                        this.containerTarget.insertAdjacentHTML("beforeend", data.html)
                    }

                    trigger.dataset.itemsUntilNextAd = data.items_until_next_ad
                    trigger.dataset.adIndex = data.ad_index

                    const currentCards = Array.from(this.element.querySelectorAll('.card:not(.ad-card)'))
                    const allLoadedIds = currentCards.map(c => c.dataset.id).filter(id => id)

                    trigger.dataset.offset = allLoadedIds.length
                    trigger.dataset.loadedIds = allLoadedIds.join(',')

                    console.log(`✅ [LoadMore] Chargé. Total items: ${allLoadedIds.length}`)

                    // Force layout recalc/validate alignment
                    this.element.querySelectorAll(".card, .ad-card").forEach(c => c.style.marginBottom = "10px")

                    setTimeout(() => {
                        this.isLoading = false
                        this.checkAndFillScreen()
                    }, 100)
                }
            })
            .catch(err => {
                console.error("💥 [LoadMore] Error:", err)
                this.isLoading = false
            })
    }

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
            if (deltaX > 0) window.location.href = '/designers'
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
        this.moveToCard(direction)
        setTimeout(() => { this.isScrolling = false }, this.cooldownValue)
    }

    moveToCard(direction) {
        const cards = Array.from(this.element.querySelectorAll(".card, .ad-card"))
        if (cards.length === 0) return

        const container = this.element
        const viewCenter = container.scrollTop + (container.clientHeight / 2)

        // Debug index calculation
        let currentIndex = cards.findIndex(card => {
            const cardTop = card.offsetTop
            const cardBottom = cardTop + card.offsetHeight
            // Log logic for the first few cards to debug
            // console.log(`Card top: ${cardTop}, bottom: ${cardBottom}, viewCenter: ${viewCenter}`)
            return cardTop <= viewCenter && cardBottom >= viewCenter
        })

        if (currentIndex === -1) {
            console.warn("⚠️ [MoveToCard] Index introuvable, reset à 0")
            currentIndex = 0
        }

        let targetIndex = currentIndex + direction
        console.log(`📍 [Navigation] Current: ${currentIndex} -> Target: ${targetIndex} (Total: ${cards.length})`)

        if (targetIndex >= cards.length - 1) {
            console.log("👇 [Navigation] Atteint la fin -> LoadMore")
            this.loadMore()
        }

        if (targetIndex < 0) targetIndex = 0
        if (targetIndex >= cards.length) targetIndex = cards.length - 1

        const targetCard = cards[targetIndex]
        targetCard.scrollIntoView({ behavior: "smooth", block: "start" })
    }
}