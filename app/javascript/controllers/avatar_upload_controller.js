import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewImg", "placeholder", "removeInput"]

  triggerInput() {
    this.inputTarget.click()
  }

  preview(event) {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewImgTarget) {
        this.previewImgTarget.src = e.target.result
        this.previewImgTarget.style.display = 'block'
      }
      
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.style.display = 'none'
      }
      
      if (this.hasRemoveInputTarget) {
        this.removeInputTarget.value = "0"
      }
      
      const deleteBtn = this.element.querySelector('.button.delete')
      if (deleteBtn) {
        deleteBtn.style.display = 'block'
      }
    }
    reader.readAsDataURL(file)
  }

  remove(event) {
    if (event) event.preventDefault()
    
    if (this.hasRemoveInputTarget) {
      this.removeInputTarget.value = "1"
    }
    
    this.inputTarget.value = ""
    
    if (this.hasPreviewImgTarget) {
      this.previewImgTarget.src = ""
      this.previewImgTarget.style.display = 'none'
    }
    
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.style.display = 'flex'
    }
    
    const deleteBtn = this.element.querySelector('.button.delete')
    if (deleteBtn) deleteBtn.style.display = 'none'
  }
}
