// app/javascript/controllers/horizontal_scroll_controller.js
import { Controller } from "@hotwired/stimulus"
import gsap from "gsap"
import ScrollTrigger from "gsap/ScrollTrigger"

gsap.registerPlugin(ScrollTrigger)

// Connects to data-controller="horizontal-scroll"
export default class extends Controller {
    static targets = ["section", "wrapper"]

    connect() {
        if (!this.hasSectionTarget || !this.hasWrapperTarget) return

        const totalScroll = this.wrapperTarget.scrollWidth

        gsap.to(this.wrapperTarget, {
            x: () => -totalScroll + window.innerWidth,
            ease: "none",
            scrollTrigger: {
                trigger: this.sectionTarget,
                start: "top top",
                end: () => "+=" + totalScroll,
                scrub: true,
                anticipatePin: 1,
            }
        })
    }
}
