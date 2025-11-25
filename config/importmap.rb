# Application
pin "application", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# IMPORTANT : On épingle le shim explicitement pour être sûr qu'il est disponible
pin "es-module-shims", to: "https://ga.jspm.io/npm:es-module-shims@1.10.0/dist/es-module-shims.js"

# Hotwire
pin "@hotwired/turbo", to: "@hotwired--turbo.js"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# jQuery (Via JSPM)
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
pin "jquery_provider", to: "jquery_provider.js"
pin "select2", to: "https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"

# Autres
pin "gsap", to: "https://cdn.jsdelivr.net/npm/gsap@3.12.5/index.js"
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js"
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.2/modular/sortable.esm.js"