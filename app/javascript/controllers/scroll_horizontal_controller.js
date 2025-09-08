import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"
import { ScrollTrigger } from "gsap/ScrollTrigger"

export default class extends Controller {
    connect() {
        console.log("Scroll horizontal controller connecté")

        gsap.registerPlugin(ScrollTrigger)

        const section = this.element.querySelector(".horizontal-scroll-section")
        const wrapper = this.element.querySelector(".horizontal-wrapper")

        if (!section || !wrapper) {
            console.warn("Section ou wrapper introuvable")
            return
        }

        // largeur totale du contenu à scroller
        const totalScroll = wrapper.scrollWidth - window.innerWidth

        gsap.to(wrapper, {
            x: () => -totalScroll,
            ease: "none",
            scrollTrigger: {
                trigger: section,
                start: "top top",
                end: () => "+=" + totalScroll,
                scrub: true,
                pin: true,
                anticipatePin: 1,
            }
        })
    }
}
