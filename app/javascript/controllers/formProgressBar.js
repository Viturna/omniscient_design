document.addEventListener("DOMContentLoaded", function () {
    const inputs = document.querySelectorAll("input:not([type=hidden]), textarea, select");
    const select2Elements = $(".select2");
    const progressBar = document.querySelector(".progress-bar-form");
    const progressPercentText = document.querySelector(".progress-percent-form");

    function updateProgress() {
        let filledInputs = 0;
        let totalInputs = inputs.length + select2Elements.length;

        inputs.forEach(input => {
            if (input.type === "checkbox" || input.type === "radio") {
                if (input.checked) filledInputs++;
            } else if (input.value.trim() !== "") {
                filledInputs++;
            }
        });

        select2Elements.each(function () {
            if ($(this).val() && $(this).val().length > 0) {
                filledInputs++;
            }
        });

        let progressPercent = Math.round((filledInputs / totalInputs) * 100);
        progressBar.style.width = `${progressPercent}%`;
        progressPercentText.textContent = `${progressPercent}%`; // Met à jour le texte
    }

    inputs.forEach(input => {
        input.addEventListener("input", updateProgress);
    });

    select2Elements.on("change", updateProgress);

    updateProgress(); // Initialisation
});
