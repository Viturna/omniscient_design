import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "results", "clearBtn"]
  static values = { url: String, minLength: { type: Number, default: 2 }, delay: { type: Number, default: 300 } }

  connect() {
    this.debounceTimer = null
  }

  search() {
    const query = this.fieldTarget.value.trim()

    // Gérer visibilité du bouton clear
    if (query.length > 0) {
      this.clearBtnTarget.style.display = "block"
    } else {
      this.clearBtnTarget.style.display = "none"
    }

    if (query.length <= this.minLengthValue) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.style.display = "none"
      return
    }

    this.debounce(() => this.fetchResults(query), this.delayValue)
  }

  clear() {
    this.fieldTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.style.display = "none"
    this.clearBtnTarget.style.display = "none"
    this.fieldTarget.focus()
  }

  fetchResults(query) {
    fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`)
      .then(response => {
        if (!response.ok) throw new Error("Erreur serveur")
        return response.json()
      })
      .then(data => this.renderResults(data))
      .catch(error => {
        console.error("Erreur AJAX :", error)
        this.resultsTarget.innerHTML = "<div class='error-msg'>Erreur de chargement</div>"
      })
  }

  renderResults(data) {
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.style.display = "block"

    const createSection = (sectionData) => {
      if (!sectionData || sectionData.results.length === 0) return

      const section = document.createElement("div")
      section.classList.add("autocomplete-section")

      const title = document.createElement("p")
      title.classList.add("autocomplete-title")
      title.textContent = sectionData.title
      section.appendChild(title)

      sectionData.results.forEach((item) => {
        const suggestion = document.createElement("div")
        suggestion.classList.add("suggestion-item")

        if (item.svg || item.img) {
          const img = document.createElement("img")
          img.src = item.svg || item.img
          img.alt = item.name
          img.classList.add("suggestion-icon")
          suggestion.appendChild(img)
        }

        const label = document.createElement("div")
        label.classList.add("suggestion-label")
        label.textContent = item.name
        suggestion.appendChild(label)

        if (item.designer) {
          const designer = document.createElement("small")
          designer.classList.add("suggestion-designer")
          designer.textContent = `Designé par : ${item.designer}`
          suggestion.appendChild(designer)
        }

        suggestion.addEventListener("click", () => {
          window.location.href = item.url
        })

        section.appendChild(suggestion)
      })

      this.resultsTarget.appendChild(section)
    }

    createSection(data.domaines)
    createSection(data.designers)
    createSection(data.oeuvres)

    if (
      (!data.domaines || data.domaines.results.length === 0) &&
      (!data.designers || data.designers.results.length === 0) &&
      (!data.oeuvres || data.oeuvres.results.length === 0)
    ) {
      this.resultsTarget.innerHTML = "<div class='no-suggestion'>Aucune suggestion</div>"
    }
  }

  debounce(callback, delay) {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(callback, delay)
  }

  closeOnClickOutside(event) {
    if (!event.target.closest(".autocomplete")) {
      this.resultsTarget.style.display = "none"
    }
  }
}
