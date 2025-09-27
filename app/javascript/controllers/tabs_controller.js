// app/javascript/controllers/tabs_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "tabInput"]

  switch(event) {
    const tabName = event.currentTarget.dataset.tab

    // si tu as un champ hidden pour le tab courant
    if (this.hasTabInputTarget) {
      this.tabInputTarget.value = tabName
    }

    // construire l’URL avec le bon paramètre
    const url = new URL(window.location)
    url.searchParams.set("tab", tabName)
    url.searchParams.set("page", "1") // reset pagination si besoin

    // recharger la page
    window.location = url
  }
}
