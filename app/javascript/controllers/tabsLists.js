document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tabs button");
    const tabInput = document.getElementById("activeTab");

    function showTab(tabName) {
        document.querySelectorAll(".content-tab").forEach(tab => tab.style.display = "none");

        const activeTab = document.getElementById(tabName);
        if (activeTab) {
            activeTab.style.display = "block";
        }

        tabs.forEach(tab => tab.classList.remove("active"));
        const activeButton = document.querySelector(`.tabs button[data-tab="${tabName}"]`);
        if (activeButton) {
            activeButton.classList.add("active");
        }

        // Réinitialiser la pagination à la page 1
        const url = new URL(window.location);
        url.searchParams.set("tab", tabName);
        // url.searchParams.set("page", 1); // Remettre la pagination à 1
        window.history.pushState({}, "", url);
    }

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const tabName = this.getAttribute("data-tab");

            if (tabInput) {
                tabInput.value = tabName;
            }

            showTab(tabName);
        });
    });

    // Vérifie l'onglet actif au chargement de la page
    const activeTab = new URLSearchParams(window.location.search).get("tab") || "all";
    showTab(activeTab);
});
