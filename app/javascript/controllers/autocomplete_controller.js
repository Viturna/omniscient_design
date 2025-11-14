import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "results", "clearBtn"]
  static values = { url: String, minLength: { type: Number, default: 2 }, delay: { type: Number, default: 300 } }

  connect() {
    this.debounceTimer = null
    this.suggestions = []
    this.activeIndex = -1

    this.fieldTarget.addEventListener("keydown", (event) => this.handleKeydown(event))
    document.addEventListener("click", (event) => this.closeOnClickOutside(event))
  }

  handleKeydown(event) {
    if (!this.suggestions.length) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.moveActive(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveActive(-1)
        break
      case "Enter":
        event.preventDefault()
        if (this.activeIndex >= 0 && this.activeIndex < this.suggestions.length) {
          window.location.href = this.suggestions[this.activeIndex].url
        } else {
          const query = this.fieldTarget.value.trim()
          const exactMatch = this.suggestions.find(s => s.name.toLowerCase() === query.toLowerCase())
          if (exactMatch) window.location.href = exactMatch.url
          else if (this.suggestions.length) window.location.href = this.suggestions[0].url
          else this.fieldTarget.closest("form")?.requestSubmit()
        }
        break
      case "Escape":
        this.resultsTarget.style.display = "none"
        this.activeIndex = -1
        break
    }
  }

  moveActive(direction) {
    // retire highlight actuel
    if (this.activeIndex >= 0 && this.activeIndex < this.suggestions.length) {
      this.resultsTarget.children[this.activeIndex].classList.remove("active-suggestion")
    }

    // incrémente ou décrémente
    this.activeIndex += direction
    if (this.activeIndex < 0) this.activeIndex = this.suggestions.length - 1
    if (this.activeIndex >= this.suggestions.length) this.activeIndex = 0

    // ajoute highlight
    this.resultsTarget.children[this.activeIndex].classList.add("active-suggestion")
    this.resultsTarget.children[this.activeIndex].scrollIntoView({ block: "nearest" })
  }

  search() {
    const query = this.fieldTarget.value.trim()
    this.clearBtnTarget.style.display = query.length ? "block" : "none"

    if (query.length <= this.minLengthValue) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.style.display = "none"
      this.suggestions = []
      this.activeIndex = -1
      return
    }

    this.debounce(() => this.fetchResults(query), this.delayValue)
  }

  clear() {
    this.fieldTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.style.display = "none"
    this.clearBtnTarget.style.display = "none"
    this.suggestions = []
    this.activeIndex = -1
    this.fieldTarget.focus()
  }

  fetchResults(query) {
    fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`)
      .then(r => {
        if (!r.ok) throw new Error("Erreur serveur")
        return r.json()
      })
      .then(data => this.renderResults(data))
      .catch(e => {
        console.error("Erreur AJAX :", e)
        this.resultsTarget.innerHTML = "<div class='error-msg'>Erreur de chargement</div>"
      })
  }

  renderResults(data) {
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.style.display = "block"
    this.suggestions = []
    this.activeIndex = -1

    const createSection = (sectionData) => {
      if (!sectionData || !sectionData.results.length) return

      const section = document.createElement("div")
      section.classList.add("autocomplete-section")

      const title = document.createElement("p")
      title.classList.add("autocomplete-title")
      title.textContent = sectionData.title
      section.appendChild(title)

      sectionData.results.forEach(item => {
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

        suggestion.addEventListener("click", () => window.location.href = item.url)

        this.suggestions.push(item)
        this.resultsTarget.appendChild(suggestion)
      })
    }

    createSection(data.domaines)
    createSection(data.designers)
    createSection(data.oeuvres)
    createSection(data.studios)

    if (!this.suggestions.length) {
      this.resultsTarget.innerHTML = "<div class='no-suggestion'>Aucune suggestion</div>"
    }
  }

  debounce(fn, delay) {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(fn, delay)
  }

  closeOnClickOutside(event) {
    if (!event.target.closest(".autocomplete")) {
      this.resultsTarget.style.display = "none"
      this.activeIndex = -1
    }
  }
}
