import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 800 },
        threshold: { type: Number, default: 50 }
    }

    connect() {
        this.isScrolling = false

        this.handleWheel = this.handleWheel.bind(this)
        this.element.addEventListener("wheel", this.handleWheel, { passive: false })

        this.handleTouchStart = this.handleTouchStart.bind(this)
        this.handleTouchMove = this.handleTouchMove.bind(this)
        this.handleTouchEnd = this.handleTouchEnd.bind(this)

        this.element.addEventListener("touchstart", this.handleTouchStart, { passive: false })
        this.element.addEventListener("touchmove", this.handleTouchMove, { passive: false })
        this.element.addEventListener("touchend", this.handleTouchEnd)
    }

    disconnect() {
        this.element.removeEventListener("wheel", this.handleWheel)
        this.element.removeEventListener("touchstart", this.handleTouchStart)
        this.element.removeEventListener("touchmove", this.handleTouchMove)
        this.element.removeEventListener("touchend", this.handleTouchEnd)
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

        if (targetIndex < 0) targetIndex = 0
        if (targetIndex >= cards.length) targetIndex = cards.length - 1

        const targetCard = cards[targetIndex]
        targetCard.scrollIntoView({ behavior: "smooth", block: "start" })
    }
}