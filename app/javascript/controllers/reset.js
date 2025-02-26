document.addEventListener("DOMContentLoaded", function () {
    const searchField = document.getElementById("workSearch");
    const clearButton = document.getElementById("clearSearch");
    const suggestionsBox = document.querySelector(".suggestions-box"); // Votre boîte de suggestions

    // Afficher la croix lorsque l'utilisateur tape quelque chose dans l'input
    searchField.addEventListener("input", function () {
        if (searchField.value.trim() !== "") {
            clearButton.style.display = "flex"; // Afficher la croix
        } else {
            clearButton.style.display = "none"; // Cacher la croix si l'input est vide
        }
    });

    // Effacer l'input et masquer les suggestions lorsque l'utilisateur clique sur la croix
    clearButton.addEventListener("click", function () {
        searchField.value = ""; // Effacer l'input
        clearButton.style.display = "none"; // Cacher la croix après effacement
        suggestionsBox.innerHTML = ""; // Masquer les suggestions
        searchField.focus(); // Remettre le focus sur l'input
    });
});
