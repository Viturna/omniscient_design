import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 500 },
        threshold: { type: Number, default: 50 }
    }
    static targets = ["container", "trigger"]

    connect() {
        this.isScrolling = false
        this.isLoading = false

        this.handleWheel = this.handleWheel.bind(this)
        this.handleKeydown = this.handleKeydown.bind(this)
        this.handleTouchStart = this.handleTouchStart.bind(this)
        this.handleTouchMove = this.handleTouchMove.bind(this)
        this.handleTouchEnd = this.handleTouchEnd.bind(this)

        this.element.addEventListener("wheel", this.handleWheel, { passive: false })
        document.addEventListener("keydown", this.handleKeydown)
        this.element.addEventListener("touchstart", this.handleTouchStart, { passive: false })
        this.element.addEventListener("touchmove", this.handleTouchMove, { passive: false })
        this.element.addEventListener("touchend", this.handleTouchEnd)

        setTimeout(() => this.checkAndFillScreen(), 200)
    }

    disconnect() {
        this.element.removeEventListener("wheel", this.handleWheel)
        document.removeEventListener("keydown", this.handleKeydown)
        this.element.removeEventListener("touchstart", this.handleTouchStart)
        this.element.removeEventListener("touchmove", this.handleTouchMove)
        this.element.removeEventListener("touchend", this.handleTouchEnd)
    }

    scrollUp(event) {
        if (event) event.preventDefault()
        this.triggerScroll(-1)
    }

    scrollDown(event) {
        if (event) event.preventDefault()
        this.triggerScroll(1)
    }

    handleKeydown(event) {
        if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return

        if (event.key === "ArrowUp") {
            event.preventDefault()
            this.triggerScroll(-1)
        } else if (event.key === "ArrowDown") {
            event.preventDefault()
            this.triggerScroll(1)
        }
    }

    checkAndFillScreen() {
        if (!this.hasTriggerTarget) return

        const container = this.element
        if (container.scrollHeight <= container.clientHeight + 100) {
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
        let loadedDesignerIds = trigger.dataset.loadedDesignerIds || ''
        let loadedStudioIds = trigger.dataset.loadedStudioIds || ''
        let itemsUntilNextAd = trigger.dataset.itemsUntilNextAd
        let adIndex = trigger.dataset.adIndex
        let adsOrder = trigger.dataset.adsOrder

        let baseUrl = window.location.pathname.includes("designers") ? "/designers/load_more" : "/oeuvres/load_more"

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

        fetch(url, { headers: { 'Accept': 'application/json' } })
            .then(response => response.json())
            .then(data => {
                if (data.html.trim() === "") {
                    trigger.style.display = "none"
                } else {
                    if (this.hasContainerTarget) {
                        this.containerTarget.insertAdjacentHTML("beforeend", data.html)
                    }

                    trigger.dataset.itemsUntilNextAd = data.items_until_next_ad
                    trigger.dataset.adIndex = data.ad_index

                    if (window.location.pathname.includes("designers")) {
                        const designerWrappers = Array.from(this.element.querySelectorAll('.entity-wrapper[data-entity-type="designer"]'))
                        const studioWrappers = Array.from(this.element.querySelectorAll('.entity-wrapper[data-entity-type="studio"]'))

                        const allLoadedDesignerIds = designerWrappers.map(el => el.dataset.id).filter(id => id)
                        const allLoadedStudioIds = studioWrappers.map(el => el.dataset.id).filter(id => id)

                        trigger.dataset.offset = allLoadedDesignerIds.length + allLoadedStudioIds.length
                        trigger.dataset.loadedDesignerIds = allLoadedDesignerIds.join(',')
                        trigger.dataset.loadedStudioIds = allLoadedStudioIds.join(',')
                    } else {
                        const currentCards = Array.from(this.element.querySelectorAll('.card:not(.partner-card)'))
                        const allLoadedIds = currentCards.map(c => c.dataset.id).filter(id => id)

                        trigger.dataset.offset = allLoadedIds.length
                        trigger.dataset.loadedIds = allLoadedIds.join(',')
                    }

                    this.element.querySelectorAll(".card, .partner-card").forEach(c => c.style.marginBottom = "10px")

                    setTimeout(() => {
                        this.isLoading = false
                        this.checkAndFillScreen()
                    }, 100)
                }
            })
            .catch(err => {
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
            if (deltaX > 0 && window.location.pathname === '/') window.location.href = '/designers'
            if (deltaX < 0 && window.location.pathname.includes('designers')) window.location.href = '/oeuvres'
            return
        }

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
        const cards = Array.from(this.element.querySelectorAll(".card, .partner-card"))
            .filter(c => c.getBoundingClientRect().height > 0)

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

        const nearEnd = targetIndex >= cards.length - 2
        const atEndTryingToDescend = (currentIndex === cards.length - 1) && (direction === 1)

        if (nearEnd || atEndTryingToDescend) {
            this.loadMore()
        }

        if (targetIndex < 0) targetIndex = 0
        if (targetIndex >= cards.length) targetIndex = cards.length - 1

        const targetCard = cards[targetIndex]
        if (targetCard) {
            targetCard.scrollIntoView({ behavior: "smooth", block: "start" })
        }
    }
}