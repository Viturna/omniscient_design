// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails"
import { Rails } from "@rails/ujs"
import { ActiveStorage } from "@rails/activestorage"
import "channels"
import "nested_forms"

// Initialisation
Rails.start()
Turbo.start()
ActiveStorage.start()

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
