// app/assets/javascripts/application.js
//= require jquery
//= require_tree .
//= require rails-ujs
//= require select2
//= require cookies_eu
import "chartkick"
import "Chart.bundle"

document.addEventListener("DOMContentLoaded", function () {
  document.addEventListener('click', function (event) {
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
import "@rails/request.js"
