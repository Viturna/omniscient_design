import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

document.addEventListener("DOMContentLoaded", () => {
    const section = document.querySelector(".horizontal-scroll-section");
    const wrapper = document.querySelector(".horizontal-wrapper");
    if (!section || !wrapper) return;

    const totalScroll = wrapper.scrollWidth;

    gsap.to(wrapper, {
        x: () => -totalScroll + window.innerWidth,
        ease: "none",
        scrollTrigger: {
            trigger: section,
            start: "top top",
            end: () => "+=" + totalScroll,
            scrub: true,
            pin: true,
            anticipatePin: 1,
        }
    });
});