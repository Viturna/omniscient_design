document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".oeuvres-counter").forEach(counter => {
        counter.addEventListener("click", function () {
            let hiddenOeuvres = this.querySelector(".hidden-oeuvres");
            if (hiddenOeuvres.style.display === "none" || hiddenOeuvres.style.display === "") {
                hiddenOeuvres.style.display = "flex";
            } else {
                hiddenOeuvres.style.display = "none";
            }
        });
    });
});