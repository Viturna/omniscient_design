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

    function updateSortOptions(tabName) {
        const sortFilter = document.getElementById("sortFilterContainer");
        const sortSelect = document.getElementById("sortSelect");

        if (tabName === "frise") {
            sortFilter.style.display = "none";
            return;
        }

        sortFilter.style.display = "flex";
        let options = [];

        if (tabName === "references") {
            options = [
                { text: "Nom A-Z", value: "nom_asc" },
                { text: "Nom Z-A", value: "nom_desc" },
                { text: "Date œuvre (ancien → récent)", value: "oeuvre_asc" },
                { text: "Date œuvre (récent → ancien)", value: "oeuvre_desc" },
            ];
        } else if (tabName === "designers") {
            options = [
                { text: "Nom A-Z", value: "nom_asc" },
                { text: "Nom Z-A", value: "nom_desc" },
                { text: "Date naissance (ancien → récent)", value: "naissance_asc" },
                { text: "Date naissance (récent → ancien)", value: "naissance_desc" },
            ];
        }

        sortSelect.innerHTML = "";
        options.forEach(opt => {
            const option = document.createElement("option");
            option.value = opt.value;
            option.textContent = opt.text;
            sortSelect.appendChild(option);
        });
    }

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const tabName = this.getAttribute("data-tab");
            updateSortOptions(tabName);
        });
    });



    // Vérifie l'onglet actif au chargement de la page
    const activeTab = new URLSearchParams(window.location.search).get("tab") || "designers";
    toggleNotionsFilter(activeTab);
    toggleCountryFilter(activeTab);
    updateSortOptions(activeTab);
});