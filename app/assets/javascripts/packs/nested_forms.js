// app/javascript/packs/nested_forms.js
document.addEventListener("turbolinks:load", function() {
  function removeFields(event) {
    event.preventDefault();
    let field = event.target.closest(".nested-fields");
    field.querySelector("input[name*='_destroy']").value = 1;
    field.style.display = "none";
  }

  function addFields(event) {
    event.preventDefault();
    let time = new Date().getTime();
    let link = event.currentTarget;
    let assoc = link.dataset.association;
    let template = document.querySelector("#" + assoc + "_fields_template").innerHTML;
    let newFields = template.replace(/new_[a-z]+/g, "new_" + time);
    link.insertAdjacentHTML('beforebegin', newFields);
  }

  document.querySelectorAll(".remove_question").forEach(link => {
    link.addEventListener("click", removeFields);
  });

  document.querySelectorAll(".remove_answer").forEach(link => {
    link.addEventListener("click", removeFields);
  });

  document.querySelector("#add_question").addEventListener("click", addFields);

  document.addEventListener("click", function(event) {
    if (event.target.matches(".add_answer")) {
      addFields(event);
    } else if (event.target.matches(".remove_answer")) {
      removeFields(event);
    } else if (event.target.matches(".remove_question")) {
      removeFields(event);
    }
  });
});
