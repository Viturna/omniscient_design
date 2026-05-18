import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "removeInput", "circle"]

  triggerInput() {
    this.inputTarget.click()
  }

  preview(event) {
    console.log("Preview triggered!")
    const file = this.inputTarget.files[0]
    if (!file) {
      console.log("No file selected.")
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      console.log("File read successful!")
      try {
        let img = this.previewTarget
        console.log("Found preview target:", img.tagName)
        
        if (img.tagName.toUpperCase() !== 'IMG') {
          console.log("Replacing placeholder with IMG tag...")
          const newImg = document.createElement('img')
          newImg.className = 'avatar-image'
          newImg.dataset.avatarUploadTarget = 'preview'
          newImg.src = e.target.result
          this.circleTarget.insertBefore(newImg, this.previewTarget)
          this.previewTarget.remove()
        } else {
          console.log("Updating existing IMG tag...")
          img.src = e.target.result
        }
        
        if (this.hasRemoveInputTarget) {
          this.removeInputTarget.value = "0"
        }
        
        const deleteBtn = this.element.querySelector('.button.delete')
        if (deleteBtn) {
          deleteBtn.style.display = 'block'
        }
        console.log("Preview update complete.")
      } catch (err) {
        console.error("Error updating preview:", err)
      }
    }
    reader.onerror = (err) => console.error("Error reading file:", err)
    reader.readAsDataURL(file)
  }

  remove() {
    // Flag for backend deletion
    if (this.hasRemoveInputTarget) {
      this.removeInputTarget.value = "1"
    }
    
    // Clear file input
    this.inputTarget.value = ""
    
    // Switch preview back to placeholder
    if (this.previewTarget.tagName === 'IMG') {
      const placeholder = document.createElement('div')
      placeholder.className = 'avatar-placeholder'
      placeholder.dataset.avatarUploadTarget = 'preview'
      
      const span = document.createElement('span')
      span.className = 'avatar-initials'
      span.textContent = '?'
      placeholder.appendChild(span)
      
      this.circleTarget.insertBefore(placeholder, this.previewTarget)
      this.previewTarget.remove()
    }
    
    // Hide delete button
    const deleteBtn = this.element.querySelector('.button.delete')
    if (deleteBtn) deleteBtn.style.display = 'none'
  }
}
