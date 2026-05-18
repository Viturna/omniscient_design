import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progress", "length", "uppercase", "number", "special"]

  check() {
    const val = this.inputTarget.value
    
    // Validation checks
    const hasLength = val.length >= 6
    const hasUpper = /[A-Z]/.test(val)
    const hasNumber = /[0-9]/.test(val)
    const hasSpecial = /[^A-Za-z0-9]/.test(val)
    
    // Update labels
    this.updateRequirement(this.lengthTarget, hasLength)
    this.updateRequirement(this.uppercaseTarget, hasUpper)
    this.updateRequirement(this.numberTarget, hasNumber)
    this.updateRequirement(this.specialTarget, hasSpecial)
    
    const score = [hasLength, hasUpper, hasNumber, hasSpecial].filter(Boolean).length
    
    // Update progress bar
    let color = "#E61818" // Red for weak
    if (score === 3) color = "#FFA500" // Orange for fair
    if (score === 4) color = "#34A853" // Green for strong
    if (score === 0) color = "#333"
    
    this.progressTarget.style.width = `${(score / 4) * 100}%`
    this.progressTarget.style.backgroundColor = color
  }
  
  updateRequirement(target, isMet) {
    if (isMet) {
      target.style.color = "#34A853"
    } else {
      target.style.color = "#aaa"
    }
  }
}
