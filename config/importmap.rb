# config/importmap.rb
pin "application", preload: true
pin "jquery" # @3.7.1
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/ujs", to: "rails-ujs.js"



pin "references_overlay", to: "references_overlay.js", preload: true
