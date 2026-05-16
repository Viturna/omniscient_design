import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "questionsData", "currentIndex", "progressPercentage", "progressBar", "questionTitle", 
    "instruction", "answersContainer", "totalPoints", "motivationMsg", "pointsFeedback",
    "prevBtn", "nextBtn", "resultModal", "finalScore", "imageContainer", "questionImage"
  ]
  
  static values = {
    quizId: Number,
    submitUrl: String,
    saveUrl: String,
    initialProgress: Object
  }

  initialize() {
    this.index = 0
    this.userAnswers = {}
    this.score = 0
    this.questions = []
    this.reviewMode = false
    this.quizFinished = false
  }

  connect() {
    try {
      this.questions = JSON.parse(this.questionsDataTarget.textContent)
      
      // Load initial progress if available
      if (this.hasInitialProgressValue) {
        this.index = this.initialProgressValue.index || 0
        this.userAnswers = this.initialProgressValue.userAnswers || {}
        // Convert keys to numbers if they are strings from JSON
        Object.keys(this.userAnswers).forEach(key => {
          if (typeof key === 'string') {
            const val = this.userAnswers[key]
            delete this.userAnswers[key]
            this.userAnswers[parseInt(key)] = val
          }
        })
      }

      console.log("Quiz initialized at index:", this.index)
      this.renderQuestion()
      this.updateProgress()
    } catch (e) {
      console.error("Failed to parse quiz questions:", e)
    }
  }

  renderQuestion() {
    const question = this.questions[this.index]
    if (!question) return

    this.questionTitleTarget.textContent = question.content
    this.currentIndexTarget.textContent = this.index + 1
    this.answersContainerTarget.innerHTML = ""
    this.instructionTarget.style.color = ""

    // Gestion de l'image de la question
    if (this.hasImageContainerTarget && this.hasQuestionImageTarget) {
      if (question.reference_image_url) {
        this.questionImageTarget.src = question.reference_image_url
        this.imageContainerTarget.classList.remove("hidden")
      } else {
        this.imageContainerTarget.classList.add("hidden")
        this.questionImageTarget.src = ""
      }
    }
    
    const selectedId = this.userAnswers[this.index]
    if (selectedId) {
      const question = this.questions[this.index]
      const selectedAnswer = question.quiz_answers.find(a => a.id === selectedId)
      if (selectedAnswer?.is_correct) {
        this.instructionTarget.textContent = "Bravo ! Bonne réponse."
        this.instructionTarget.style.color = "#22C55E"
      } else {
        this.instructionTarget.textContent = "Oups ! Mauvaise réponse."
        this.instructionTarget.style.color = "#EF4444"
      }
    } else {
      this.instructionTarget.textContent = "Sélectionnez la bonne réponse"
    }
    
    // Reset points feedback
    this.pointsFeedbackTarget.classList.add("hidden")

    const answers = question.quiz_answers || []
    const hasImages = answers.some(a => this.isImageUrl(a.content))
    
    if (hasImages) {
      this.answersContainerTarget.classList.add("has-images")
    } else {
      this.answersContainerTarget.classList.remove("has-images")
    }

    answers.forEach(answer => {
      const button = document.createElement("button")
      button.className = "answer-btn"
      
      // Si déjà répondu (retour en arrière), montrer le résultat
      const selectedId = this.userAnswers[this.index]
      if (selectedId) {
        button.disabled = true
        if (answer.is_correct) button.classList.add("correct")
        if (selectedId === answer.id && !answer.is_correct) button.classList.add("incorrect")
      } else {
        button.dataset.action = "click->quiz-player#selectAnswer"
      }
      
      if (this.isImageUrl(answer.content)) {
        const img = document.createElement("img")
        img.src = answer.content
        img.className = "answer-img"
        button.appendChild(img)
        button.classList.add("with-image")
      } else {
        button.textContent = answer.content
      }
      
      button.dataset.answerId = answer.id
      button.dataset.isCorrect = answer.is_correct
      this.answersContainerTarget.appendChild(button)
    })

    this.updateControls()
  }

  review() {
    this.reviewMode = true
    this.index = 0
    this.resultModalTarget.classList.add("hidden")
    this.renderQuestion()
    this.updateProgress()
  }

  selectAnswer(event) {
    if (this.userAnswers[this.index] || this.reviewMode) return

    const button = event.currentTarget
    const answerId = parseInt(button.dataset.answerId)
    const isCorrect = button.dataset.isCorrect === "true"
    
    this.userAnswers[this.index] = answerId
    
    this.answersContainerTarget.querySelectorAll(".answer-btn").forEach(btn => {
      btn.disabled = true
      if (btn.dataset.isCorrect === "true") btn.classList.add("correct")
      else if (parseInt(btn.dataset.answerId) === answerId) btn.classList.add("incorrect")
    })
    
    // Feedback points
    this.pointsFeedbackTarget.classList.remove("hidden")
    this.pointsFeedbackTarget.textContent = isCorrect ? "+10 points" : "0 points"
    this.pointsFeedbackTarget.style.color = isCorrect ? "#22C55E" : "#EF4444"

    if (isCorrect) {
      this.instructionTarget.textContent = "Bravo ! Bonne réponse."
      this.instructionTarget.style.color = "#22C55E"
    } else {
      this.instructionTarget.textContent = "Oups ! Mauvaise réponse."
      this.instructionTarget.style.color = "#EF4444"
    }

    this.updateControls()
    this.saveProgress()
  }

  saveProgress() {
    if (this.reviewMode || !this.hasSaveUrlValue) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(this.saveUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        current_index: this.index,
        user_answers: this.userAnswers
      })
    })
    .catch(error => console.error("Failed to save progress:", error))
  }

  next() {
    if (!this.reviewMode && !this.userAnswers[this.index]) {
      // Ce cas ne devrait plus arriver car le bouton est désactivé
      return
    }

    if (this.index < this.questions.length - 1) {
      this.index++
      this.renderQuestion()
      this.updateProgress()
      
      // Reset instruction style
      this.instructionTarget.style.color = ""
      this.instructionTarget.textContent = this.questions[this.index].instruction || "Sélectionnez la bonne réponse"
    } else {
      this.finish()
    }
  }

  prev() {
    if (this.index > 0) {
      this.index--
      this.renderQuestion()
      this.updateProgress()
    }
  }

  updateProgress() {
    const progress = Math.round(((this.index + 1) / this.questions.length) * 100)
    this.progressPercentageTarget.textContent = `${progress}%`
    this.progressBarTarget.style.width = `${progress}%`
  }

  updateControls() {
    this.prevBtnTarget.disabled = this.index === 0
    
    if (this.reviewMode) {
      this.nextBtnTarget.disabled = false
    } else {
      this.nextBtnTarget.disabled = !this.userAnswers[this.index]
    }
    
    this.nextBtnTarget.textContent = (this.index === this.questions.length - 1) ? "Terminer" : "Suivant"
  }

  isImageUrl(url) {
    return url && (url.startsWith("/") || url.startsWith("http")) && (url.match(/\.(jpeg|jpg|gif|png|webp)/i) || url.includes("rails/active_storage"))
  }

  finish() {
    // Calcul du score (10 pts par bonne réponse)
    this.score = 0
    this.questions.forEach((q, i) => {
      const selectedAnswerId = this.userAnswers[i]
      const correctAnswer = q.quiz_answers.find(a => a.is_correct)
      if (selectedAnswerId === correctAnswer.id) {
        this.score += 10
      }
    })

    this.submitScore()
  }

  submitScore() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) {
      console.error("CSRF token not found")
      this.showResultModal() // Fallback
      return
    }

    fetch(this.submitUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ 
        score: this.score,
        user_answers: this.userAnswers
      })
    })
    .then(response => {
      if (!response.ok) throw new Error("Server error")
      return response.json()
    })
    .then(data => {
      if (data.status === "success") {
        if (this.hasTotalPointsTarget) this.totalPointsTarget.textContent = `${data.total_points} pts`
        this.showResultModal()
      }
    })
    .catch(error => {
      console.error("Failed to submit score:", error)
      this.showResultModal() // Toujours montrer la modal pour ne pas bloquer l'utilisateur
    })
  }

  showResultModal() {
    this.quizFinished = true
    if (this.hasFinalScoreTarget) this.finalScoreTarget.textContent = this.score
    if (this.hasResultModalTarget) this.resultModalTarget.classList.remove("hidden")
  }
}
