document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tabs button");
    const tabInput = document.getElementById("activeTab");

    function showTab(tabName) {
        document.querySelectorAll(".content-tab").forEach(tab => tab.style.display = "none");
        document.getElementById(tabName).style.display = "block";

        tabs.forEach(tab => tab.classList.remove("active"));
        document.querySelector(`.tabs button[data-tab="${tabName}"]`).classList.add("active");

        // Réinitialiser la pagination à la page 1
        const url = new URL(window.location);
        url.searchParams.set("tab", tabName);
        url.searchParams.set("page", 1); // Remettre la pagination à 1
        window.history.pushState({}, "", url);
    }

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const tabName = this.getAttribute("data-tab");
            tabInput.value = tabName;
            showTab(tabName);
        });
    });

    // Vérifie l'onglet actif au chargement de la page
    const activeTab = new URLSearchParams(window.location.search).get("tab") || "designers";
    showTab(activeTab);
});


document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tabs button");
    const notionsFilter = document.getElementById("notionsFilterContainer");
    const countryFilter = document.getElementById("countryFilterContainer");

    function toggleNotionsFilter(tabName) {
        if (tabName === "designers") {
            notionsFilter.style.display = "none";
        } else {
            notionsFilter.style.display = "flex";
        }
    }


    function toggleCountryFilter(tabName) {
        if (tabName === "references") {
            countryFilter.style.display = "none";
        } else {
            countryFilter.style.display = "flex";
        }
    }

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const tabName = this.getAttribute("data-tab");
            toggleNotionsFilter(tabName);
            toggleCountryFilter(tabName);
        });
    });

    // Vérifie l'onglet actif au chargement de la page
    const activeTab = new URLSearchParams(window.location.search).get("tab") || "designers";
    toggleNotionsFilter(activeTab);
    toggleCountryFilter(activeTab);
});