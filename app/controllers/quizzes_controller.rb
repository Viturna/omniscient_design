class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz, only: [:show, :submit]

  def index
    @quizzes_by_domaine = Quiz.where(quiz_type: 'static')
                             .joins(:quiz_questions)
                             .group('quizzes.id')
                             .having('count(quiz_questions.id) >= 10')
                             .group_by(&:domaine)
    @user_lists = current_user.lists.joins(:references).group('lists.id').having('count("references".id) >= 5')
    @recent_submissions = current_user.quiz_submissions.order(created_at: :desc).limit(4).includes(:quiz)
    @daily_quiz = Quiz.where(quiz_type: 'static').order("RANDOM()").first
  end

  def show
    @questions = @quiz.quiz_questions.includes(:quiz_answers).order(:order)
    
    # Préparer les données JSON avec les URLs d'images
    @questions_json = @questions.map do |q|
      {
        id: q.id,
        content: q.content,
        reference_image_url: q.reference_id ? get_image_url(Reference.find(q.reference_id)) : nil,
        quiz_answers: q.quiz_answers.map { |a|
          {
            id: a.id,
            content: a.content,
            is_correct: a.is_correct
          }
        }.shuffle
      }
    end
  end

  def submit
    score = params[:score].to_i
    
    submission = QuizSubmission.create!(
      user: current_user,
      quiz: @quiz,
      score: score,
      completed_at: Time.current
    )

    # Ajouter les points au profil de l'utilisateur
    current_user.increment!(:quiz_points, score)

    render json: { 
      status: 'success', 
      total_points: current_user.quiz_points,
      submission_id: submission.id 
    }
  end

  def generate_from_list
    list = current_user.lists.find(params[:list_id])
    
    # On peut soit créer un nouveau quiz à chaque fois, soit réutiliser un existant
    # Ici on va en créer un nouveau pour la fraîcheur des questions dynamiques
    quiz = QuizGeneratorService.new(list, current_user).call
    
    redirect_to quiz_path(quiz)
  end

  private

  def get_image_url(reference)
    image = reference.reference_images.first
    return nil unless image&.file&.attached?
    
    Rails.application.routes.url_helpers.rails_representation_url(
      image.file.variant(resize_to_fill: [600, 400]).processed,
      only_path: true
    )
  end

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end
end
