class Admin::QuizzesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_quiz, only: [:edit, :update, :destroy]

  def index
    @current_page = 'quizzes'
    @quizzes = Quiz.where(quiz_type: 'static')
                   .includes(:domaine, :quiz_questions)
                   .order(created_at: :desc)
  end

  def stats
    @current_page = 'quizzes'
    @total_submissions = QuizSubmission.count
    @avg_score = QuizSubmission.average(:score)
    @quizzes_stats = Quiz.where(quiz_type: 'static')
                         .joins(:quiz_submissions)
                         .select('quizzes.*, COUNT(quiz_submissions.id) as submissions_count, AVG(quiz_submissions.score) as average_score')
                         .group('quizzes.id')
                         .order('submissions_count DESC')
  end

  def sessions
    @current_page = 'quizzes'
    @submissions = QuizSubmission.includes(:user, :quiz).order(created_at: :desc).limit(100)
  end

  def auto_generate
    @quiz = Admin::QuizGeneratorService.new(auto_generate_params).call
    redirect_to admin_quizzes_path, notice: "Le quiz '#{@quiz.title}' a été généré avec succès.", status: :see_other
  rescue => e
    redirect_to admin_quizzes_path, alert: "Erreur lors de la génération : #{e.message}", status: :see_other
  end

  def new
    @current_page = 'quizzes'
    @quiz = Quiz.new(quiz_type: 'static')
  end

  def create
    @quiz = Quiz.new(quiz_params)
    @quiz.quiz_type = 'static'
    if @quiz.save
      redirect_to admin_quizzes_path, notice: "Quiz créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = 'quizzes'
  end

  def update
    if @quiz.update(quiz_params)
      redirect_to admin_quizzes_path, notice: "Quiz mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to admin_quizzes_path, notice: "Quiz supprimé."
  end

  def toggle_archive
    @quiz = Quiz.find(params[:id])
    @quiz.update!(archived: !@quiz.archived)
    status_msg = @quiz.archived? ? "archivé" : "désarchivé"
    redirect_to admin_quizzes_path, notice: "Le quiz a été #{status_msg} avec succès."
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(
      :title, :domaine_id, :estimated_time, :archived,
      quiz_questions_attributes: [
        :id, :content, :reference_id, :order, :_destroy,
        quiz_answers_attributes: [:id, :content, :is_correct, :_destroy]
      ]
    )
  end

  def auto_generate_params
    params.permit(:title, :domaine_id, :count)
  end

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès interdit."
    end
  end
end
