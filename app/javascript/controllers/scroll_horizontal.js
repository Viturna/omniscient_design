document.addEventListener("DOMContentLoaded", () => {
  gsap.registerPlugin(ScrollTrigger);

  const container = document.querySelector(".oeuvres-same");

  gsap.to(container, {
    x: () => -(container.scrollWidth - window.innerWidth),
    ease: "none",
    scrollTrigger: {
      trigger: container,
      start: "top top",
      end: () => `+=${container.scrollWidth}`,
      scrub: true,
      pin: true,
    },
  });
});
