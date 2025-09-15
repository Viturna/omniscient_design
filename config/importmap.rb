# Application
pin "application", preload: true
pin "controllers", to: "controllers/index.js"
# Hotwire
pin "@hotwired/turbo", to: "@hotwired--turbo.js"
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
# jQuery + plugins
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"

pin "select2", to: "https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"
# GSAP
pin "gsap", to: "https://cdn.jsdelivr.net/npm/gsap@3.12.5/index.js"
pin "gsap/ScrollTrigger", to: "https://cdn.jsdelivr.net/npm/gsap@3.12.5/ScrollTrigger.js"

# Chartkick + Chart.js
pin "chartkick", to: "https://ga.jspm.io/npm:chartkick@5.0.1/dist/chartkick.js"
pin "Chart", to: "https://cdn.jsdelivr.net/npm/chart.js@4.5.0/dist/chart.umd.min.js"

# ActionCable
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.201
