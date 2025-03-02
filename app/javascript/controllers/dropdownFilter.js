document.addEventListener("DOMContentLoaded", function () {
    const dropdown = document.querySelector(".dropdown");
    const dropdownToggle = document.querySelector(".dropdown-toggle");

    // Ouvrir/Fermer le menu
    dropdownToggle.addEventListener("click", function () {
        dropdown.classList.toggle("active");
    });

    // Fermer le menu si on clique en dehors
    document.addEventListener("click", function (event) {
        if (!dropdown.contains(event.target)) {
            dropdown.classList.remove("active");
        }
    });
});