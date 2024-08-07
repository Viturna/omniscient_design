// app/javascript/packs/application.js
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("nested_forms")
// app/assets/javascripts/application.js

document.addEventListener("DOMContentLoaded", function() {
  document.addEventListener('click', function(event) {
    if (event.target.matches('.add_fields')) {
      event.preventDefault();
      var time = new Date().getTime();
      var link = event.target;
      var id = link.dataset.id;
      var regexp = new RegExp(id, 'g');
      var new_fields = link.dataset.fields.replace(regexp, time);
      link.insertAdjacentHTML('beforebegin', new_fields);
    }
  });
});
