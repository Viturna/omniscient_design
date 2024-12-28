document.addEventListener("DOMContentLoaded", () => {
  const selects = document.querySelectorAll("select[id^='country_']");

  const updateOptions = () => {
    const selectedValues = Array.from(selects)
      .map(select => select.value)
      .filter(value => value !== "");

    selects.forEach(select => {
      Array.from(select.options).forEach(option => {
        option.disabled = selectedValues.includes(option.value) && option.value !== select.value;
      });
    });
  };

  selects.forEach(select => {
    select.addEventListener("change", updateOptions);
  });

  updateOptions();
});
