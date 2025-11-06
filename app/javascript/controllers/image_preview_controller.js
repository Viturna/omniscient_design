import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "container"]

    preview(event) {
        const input = this.inputTarget
        const container = this.containerTarget
        const file = input.files[0]

        container.innerHTML = ""

        if (!file) {
            return
        }

        const reader = new FileReader()

        reader.onload = (e) => {
            const previewWrapper = document.createElement("div")
            previewWrapper.className = "existing-image-preview js-new-preview"
            previewWrapper.style = "position: relative; width: 100%; height: 400px;"

            const img = document.createElement("img")
            img.src = e.target.result
            img.className = "image-preview"
            img.style = "width: 100%; height: 100%; object-fit: cover; border-radius: 8px;"

            const deleteOverlay = document.createElement("div")
            deleteOverlay.className = "image-delete-overlay"

            const deleteBtn = document.createElement("button")
            deleteBtn.type = "button"
            deleteBtn.className = "delete-image-btn"
            deleteBtn.innerHTML = "×"
            deleteBtn.title = "Retirer l'image"
            deleteBtn.dataset.action = "click->image-preview#remove"

            deleteOverlay.appendChild(deleteBtn)
            previewWrapper.appendChild(img)
            previewWrapper.appendChild(deleteOverlay)

            container.appendChild(previewWrapper)
        }

        reader.readAsDataURL(file)
    }

    remove(event) {
        event.preventDefault()

        this.inputTarget.value = null
        this.containerTarget.innerHTML = ""
    }
}