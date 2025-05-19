document.addEventListener("DOMContentLoaded", () => {
    gsap.registerPlugin(ScrollTrigger);

    const tlHero = gsap.timeline({ defaults: { ease: "power2.out", duration: 1 } });

    tlHero
        .from(".logo-top", { opacity: 0, y: -20, duration: 0.8 })
        .from(".top-presentation-tag", { opacity: 0, x: -30 }, "-=0.6")
        .from(".text-top-presentation h1", { opacity: 0, y: 30 }, "-=0.5")
        .from(".text-top-presentation p", { opacity: 0, y: 30 }, "-=0.6")
        .from(".btn-section-top .button", {
            opacity: 0,
            y: 30,
            stagger: 0.2,
        }, "-=0.6")
        .from(".right-container", { opacity: 0, x: 50 }, "-=1");

    // === ABOUT-US SECTION ANIMATIONS ===
    gsap.utils.toArray(".about-us .container").forEach((section, index) => {
        gsap.from(section, {
            opacity: 0,
            y: 50,
            duration: 1,
            ease: "power2.out",
            scrollTrigger: {
                trigger: section,
                start: "top 80%",
                toggleActions: "play none none none",
            },
        });
    });

    // === CITATION SECTION ===
    gsap.from(".citation .citation-text", {
        opacity: 0,
        y: 40,
        duration: 1,
        ease: "power2.out",
        scrollTrigger: {
            trigger: ".citation",
            start: "top 80%",
        },
    });

    gsap.from(".citation .citation-name", {
        opacity: 0,
        y: 20,
        delay: 0.3,
        duration: 0.8,
        ease: "power2.out",
        scrollTrigger: {
            trigger: ".citation",
            start: "top 80%",
        },
    });

    // === SIMPLE SECTION WITH H2 + P ===
    gsap.from("section h2:not(.text-top-presentation h1)", {
        scrollTrigger: {
            trigger: "section h2:not(.text-top-presentation h1)",
            start: "top 80%",
        },
        opacity: 0,
        y: 30,
        duration: 1,
        ease: "power2.out",
        stagger: 0.2,
    });

    gsap.from("section p:not(.citation-text):not(.citation-name):not(.text-top-presentation p)", {
        scrollTrigger: {
            trigger: "section p:not(.citation-text):not(.citation-name):not(.text-top-presentation p)",
            start: "top 85%",
        },
        opacity: 0,
        y: 20,
        duration: 0.8,
        ease: "power2.out",
        stagger: 0.15,
    });

    // === IMAGE FADE IN ===
    gsap.utils.toArray("img:not(.first-image):not(.second-image)").forEach((img) => {
        gsap.from(img, {
            scrollTrigger: {
                trigger: img,
                start: "top 85%",
            },
            opacity: 0,
            y: 20,
            duration: 1,
            ease: "power2.out",
        });
    });

    // === Animation des images about ===
    gsap.from(".first-image", {
        scrollTrigger: {
            trigger: ".first-image",
            start: "top 90%",
            toggleActions: "play none none none"
        },
        opacity: 0,
        x: 100,
        duration: 1,
        ease: "power2.out"
    });

    gsap.from(".second-image", {
        scrollTrigger: {
            trigger: ".second-image",
            start: "top 90%",
            toggleActions: "play none none none"
        },
        opacity: 0,
        x: -100,
        duration: 1,
        ease: "power2.out"
    });

});
