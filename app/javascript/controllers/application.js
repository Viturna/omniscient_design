import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }


document.addEventListener('DOMContentLoaded', function() {
  const theme = document.body.classList.contains('system') ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') : document.body.classList.contains('dark') ? 'dark' : 'light';
  document.body.classList.add(theme);
});
