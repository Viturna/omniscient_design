import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  claim(event) {
    const url = this.urlValue || "/badges/community"
    
    // On envoie la requête POST en arrière-plan
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        "Content-Type": "application/json"
      }
    }).then(response => {
      if (response.ok) {
        console.log("Badge Community Member attribué ou vérifié !")
      }
    }).catch(error => {
      console.error("Erreur lors de l'attribution du badge:", error)
    })
  }
}
