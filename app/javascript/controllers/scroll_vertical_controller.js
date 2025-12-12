import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        cooldown: { type: Number, default: 800 }
    }

    connect() {
        this.isScrolling = false
        this.handleWheel = this.handleWheel.bind(this)

        this.element.addEventListener("wheel", this.handleWheel, { passive: false })
    }

    disconnect() {
        this.element.removeEventListener("wheel", this.handleWheel)
    }

    handleWheel(event) {
        event.preventDefault()

        if (this.isScrolling) return
        const deltaY = event.deltaY
        if (Math.abs(deltaY) < 30) return
        this.isScrolling = true

        if (deltaY > 0) {
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