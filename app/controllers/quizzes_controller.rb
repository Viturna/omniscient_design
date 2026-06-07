class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz, only: [:show, :submit]

  def index
    @current_page = 'training'
    
    if params[:category].present? || params[:domaine_id].present? || params[:count_range].present? || params[:status].present?
      @view_mode = 'explore'
      
      # Eager loading massif pour éviter les N+1 sur les domaines et questions
      base_quizzes = Quiz.active.where(quiz_type: 'static').includes(:domaine, :quiz_questions)

    # Filtrage par Domaine
    if params[:domaine_id].present?
      base_quizzes = base_quizzes.where(domaine_id: params[:domaine_id])
    end

    # Filtrage par Nombre de questions
    if params[:count_range].present?
      case params[:count_range]
      when "small"  
        base_quizzes = base_quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) < 10').select(:quiz_id))
      when "medium" 
        base_quizzes = base_quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) BETWEEN 10 AND 20').select(:quiz_id))
      when "large"  
        base_quizzes = base_quizzes.where(id: QuizQuestion.group(:quiz_id).having('count(id) > 20').select(:quiz_id))
      end
    end

    # Filtrage par Statut (lié à l'utilisateur)
    if params[:status].present? && current_user
      case params[:status]
      when "in_progress"
        in_progress_ids = current_user.quiz_submissions.where(status: 'in_progress').pluck(:quiz_id)
        base_quizzes = base_quizzes.where(id: in_progress_ids)
      when "completed"
        completed_ids = current_user.quiz_submissions.where(status: 'completed').pluck(:quiz_id)
        base_quizzes = base_quizzes.where(id: completed_ids)
      when "not_started"
        started_ids = current_user.quiz_submissions.pluck(:quiz_id)
        base_quizzes = base_quizzes.where.not(id: started_ids)
      end
    end

    base_quizzes = base_quizzes.left_joins(:domaine, :quiz_questions)
                               .group('quizzes.id, domaines.domaine')
                               .order('domaines.domaine ASC, COUNT(quiz_questions.id) ASC')
    
    @quizzes_a_la_une = base_quizzes.where('quizzes.created_at >= ?', 7.days.ago)
    @quizzes_normaux = base_quizzes.where('quizzes.created_at < ?', 7.days.ago)
    
    # Sélection spéciale pour la page d'accueil (Hub)
    target_domaines = Domaine.where(domaine: ['Architecture', 'Objet', 'Mode'])
    hub_a_la_une_ids = target_domaines.map do |d|
      @quizzes_a_la_une.where(domaine_id: d.id)
                       .left_joins(:quiz_questions)
                       .group('quizzes.id')
                       .order('COUNT(quiz_questions.id) ASC')
                       .first&.id
    end.compact
    @quizzes_jeux_a_la_une = base_quizzes.where(id: hub_a_la_une_ids)
    
    # Optimisation ultime : On pré-charge une image par quiz
    quiz_ids = base_quizzes.pluck(:id)
    
    # 1. On cherche d'abord dans les questions
    @quiz_covers = Reference.joins(:quiz_questions)
                            .where(quiz_questions: { quiz_id: quiz_ids })
                            .select('"references".*, quiz_questions.quiz_id as q_id')
                            .includes(reference_images: { file_attachment: :blob })
                            .group_by(&:q_id)
                            .transform_values(&:first)
    
    # 2. On pré-charge les images des domaines pour les fallbacks
    domaine_ids = base_quizzes.map(&:domaine_id).compact.uniq
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
                                    .joins(:quiz)
                                    .where(quizzes: { archived: false })
                                    .includes(:quiz)
                                    .order(updated_at: :desc)
                                    .limit(15)
                                    .map(&:quiz)
                                    .compact
                                    .uniq
                                    .first(4)
    else
      @view_mode = 'hub'
      
      # Quiz à la une pour la page hub : Architecture, Objet, Mode avec le moins de questions
      target_domaines = Domaine.where(domaine: ['Architecture', 'Objet', 'Mode'])
      recent_quizzes = Quiz.active.where(quiz_type: 'static').where('quizzes.created_at >= ?', 7.days.ago)
      
      hub_a_la_une_ids = target_domaines.map do |d|
        recent_quizzes.where(domaine_id: d.id)
                      .left_joins(:quiz_questions)
                      .group('quizzes.id')
                      .order('COUNT(quiz_questions.id) ASC')
                      .first&.id
      end.compact
      
      @quizzes_jeux_a_la_une = Quiz.active.where(id: hub_a_la_une_ids).includes(:domaine, :quiz_questions)
                                     
      # Préchargement des images pour la vue hub
      quiz_ids = @quizzes_jeux_a_la_une.pluck(:id)
      @quiz_covers = Reference.joins(:quiz_questions)
                              .where(quiz_questions: { quiz_id: quiz_ids })
                              .select('"references".*, quiz_questions.quiz_id as q_id')
                              .includes(reference_images: { file_attachment: :blob })
                              .group_by(&:q_id)
                              .transform_values(&:first)
                              
      domaine_ids = @quizzes_jeux_a_la_une.map(&:domaine_id).compact.uniq
      @domaine_covers = Reference.joins(:domaines)
                                 .where(domaines: { id: domaine_ids })
                                 .select('"references".*, domaines.id as d_id')
                                 .includes(reference_images: { file_attachment: :blob })
                                 .group_by(&:d_id)
                                 .transform_values(&:first)
                                 
      # Préchargement des soumissions
      @user_submissions_by_quiz = current_user.quiz_submissions.where(quiz_id: quiz_ids).index_by(&:quiz_id)
    end
  end

  def leaderboard
    @current_page = 'training'
    @leaderboard_type = params[:type] || 'season'
    
    if @leaderboard_type == 'global'
      @users = User.where('total_quiz_points > 0').order(total_quiz_points: :desc)
    else
      @users = User.where('quiz_points > 0').order(quiz_points: :desc)
    end
    
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

    # On pré-charge les références pour les réponses images dynamiques
    ref_ids_in_answers = @questions.flat_map(&:quiz_answers).map(&:content).select { |c| c.to_s.start_with?("reference_image:") }.map { |c| c.split(":").last }
    @references_for_answers = Reference.includes(reference_images: { file_attachment: :blob }).where(id: ref_ids_in_answers).index_by(&:id)

    # Préparer les données JSON avec les URLs d'images
    @questions_json = @questions.map do |q|
      {
        id: q.id,
        content: q.content,
        reference_image_url: q.reference ? get_image_url(q.reference) : nil,
        quiz_answers: q.quiz_answers.map { |a|
          processed_content = a.content
          if processed_content.to_s.start_with?("reference_image:")
            ref_id = processed_content.split(":").last.to_i
            ref = @references_for_answers[ref_id]
            processed_content = ref ? get_image_url(ref) : ""
          end

          {
            id: a.id,
            content: processed_content,
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

    # Ajouter les points au profil de l'utilisateur uniquement si c'est un quiz statique
    if submission.quiz.quiz_type == 'static'
      already_completed = current_user.quiz_submissions.where(quiz_id: submission.quiz_id, status: :completed).where.not(id: submission.id).exists?
      
      unless already_completed
        current_user.increment!(:quiz_points, score)
        current_user.increment!(:total_quiz_points, score)
        
        # Vérifier l'attribution des badges Gamer (uniquement pour les quiz officiels)
        GamificationService.new(current_user).check_gamer
      end
    end

    render json: { 
      status: 'success', 
      total_points: current_user.total_quiz_points,
      season_points: current_user.quiz_points,
      submission_id: submission.id 
    }
  end

  def generate_from_list
    list = current_user.lists.find_by(id: params[:list_id]) || 
           current_user.editable_lists.find_by(id: params[:list_id]) || 
           current_user.visitor_lists.find_by(id: params[:list_id])
    
    if list.nil?
      redirect_to root_path, alert: I18n.t('lists.access_denied', default: "Accès refusé")
      return
    end
    
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
