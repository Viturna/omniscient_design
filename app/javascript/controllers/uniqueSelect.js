document.addEventListener("DOMContentLoaded", () => {
  const updateOptions = (selects) => {
    const selectedValues = Array.from(selects)
      .map(select => select.value)
      .filter(value => value !== "");

    selects.forEach(select => {
      Array.from(select.options).forEach(option => {
        option.disabled = selectedValues.includes(option.value) && option.value !== select.value;
      });
    });
  };

  const initializeSelects = (prefix) => {
    const selects = document.querySelectorAll(`select[id^='${prefix}_']`);
    selects.forEach(select => {
      select.addEventListener("change", () => updateOptions(selects));
    });
    updateOptions(selects);
  };

  initializeSelects('country');
  initializeSelects('designer');
});
