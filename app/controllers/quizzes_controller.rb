class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz, only: [:show, :submit]

  def index
    @current_page = 'jeux'
    
    # Eager loading massif pour éviter les N+1 sur les domaines et questions
    @quizzes = Quiz.where(quiz_type: 'static').includes(:domaine, :quiz_questions)

    # Filtrage par Domaine
    if params[:domaine_id].present?
      @quizzes = @quizzes.where(domaine_id: params[:domaine_id])
    end

    # Filtrage par Nombre de questions
    if params[:count_range].present?
      case params[:count_range]
      when "small"  
        @quizzes = @quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) < 10').select(:quiz_id))
      when "medium" 
        @quizzes = @quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) BETWEEN 10 AND 20').select(:quiz_id))
      when "large"  
        @quizzes = @quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) > 20').select(:quiz_id))
      end
    end

    # Filtrage par Statut (lié à l'utilisateur)
    if params[:status].present? && current_user
      case params[:status]
      when "in_progress"
        in_progress_ids = current_user.quiz_submissions.where(status: 'in_progress').pluck(:quiz_id)
        @quizzes = @quizzes.where(id: in_progress_ids)
      when "completed"
        completed_ids = current_user.quiz_submissions.where(status: 'completed').pluck(:quiz_id)
        @quizzes = @quizzes.where(id: completed_ids)
      when "not_started"
        started_ids = current_user.quiz_submissions.pluck(:quiz_id)
        @quizzes = @quizzes.where.not(id: started_ids)
      end
    end

    @quizzes = @quizzes.order(created_at: :desc)
    
    # Optimisation ultime : On pré-charge une image par quiz
    quiz_ids = @quizzes.pluck(:id)
    
    # 1. On cherche d'abord dans les questions
    @quiz_covers = Reference.joins(:quiz_questions)
                            .where(quiz_questions: { quiz_id: quiz_ids })
                            .select('"references".*, quiz_questions.quiz_id as q_id')
                            .includes(reference_images: { file_attachment: :blob })
                            .group_by(&:q_id)
                            .transform_values(&:first)
    
    # 2. On pré-charge les images des domaines pour les fallbacks
    domaine_ids = @quizzes.map(&:domaine_id).compact.uniq
    @domaine_covers = Reference.joins(:domaines)
                               .where(domaines: { id: domaine_ids })
                               .select('"references".*, domaines.id as d_id')
                               .includes(reference_images: { file_attachment: :blob })
                               .group_by(&:d_id)
                               .transform_values(&:first)
    
    # On charge TOUTES les soumissions de l'utilisateur pour éviter les N+1 dans la vue
    @user_submissions_by_quiz = current_user.quiz_submissions.index_by(&:quiz_id)
    
    # Pour les filtres
    @user_lists = current_user.lists.joins(:references).group('lists.id').having('count("references".id) >= 5')
    
    # Quiz récents
    @recent_quizzes = current_user.quiz_submissions
                                  .includes(:quiz)
                                  .order(updated_at: :desc)
                                  .limit(10)
                                  .map(&:quiz)
                                  .compact
                                  .uniq
                                  .first(4)
  end

  def leaderboard
    @users = User.where('quiz_points > 0').order(quiz_points: :desc)
    
    if params[:query].present?
      @users = @users.where('pseudo ILIKE ?', "%#{params[:query]}%")
    end

    @users = @users.page(params[:page]).per(25)
  end

  def show
    @questions = @quiz.quiz_questions.includes(:quiz_answers, :reference).order(:order)
    
    # Trouver ou créer une session en cours
    @submission = current_user.quiz_submissions.find_or_create_by!(
      quiz: @quiz,
      status: :in_progress
    ) do |s|
      s.current_question_index = 0
      s.user_answers = {}
    end

    # Préparer les données JSON avec les URLs d'images
    @questions_json = @questions.map do |q|
      {
        id: q.id,
        content: q.content,
        reference_image_url: q.reference ? get_image_url(q.reference) : nil,
        quiz_answers: q.quiz_answers.map { |a|
          {
            id: a.id,
            content: a.content,
            is_correct: a.is_correct
          }
        }.shuffle
      }
    end

    @initial_progress = {
      index: @submission.current_question_index || 0,
      userAnswers: @submission.user_answers || {}
    }
  end

  def save_progress
    submission = current_user.quiz_submissions.find_by!(quiz_id: params[:id], status: :in_progress)
    if submission.update(
      current_question_index: params[:current_index],
      user_answers: params[:user_answers]
    )
      render json: { status: 'success' }
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  def submit
    submission = current_user.quiz_submissions.find_by!(quiz_id: params[:id], status: :in_progress)
    score = params[:score].to_i
    
    submission.update!(
      score: score,
      completed_at: Time.current,
      status: :completed,
      user_answers: params[:user_answers] # On s'assure d'avoir les dernières réponses
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
    
    quiz = QuizGeneratorService.new(list, current_user).call
    
    redirect_to quiz_path(quiz)
  end

  private

  def get_image_url(reference)
    image = reference.reference_images.first
    return nil unless image&.file&.attached?
    
    Rails.application.routes.url_helpers.rails_blob_url(image.file, only_path: true)
  rescue
    nil
  end

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end
end
