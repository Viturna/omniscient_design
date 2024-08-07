class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :check_feedback_submission, only: [:new, :create]
  before_action :set_feedback, only: [:destroy]
  before_action :check_admin_role, only: [:index]

  def index
    @feedbacks = Feedback.all

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'index', filename: "feedbacks_#{Date.today}.xlsx" }
    end
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = current_user.feedbacks.build(feedback_params) # Associe le feedback à l'utilisateur connecté

    if @feedback.save
      redirect_to root_path, notice: 'Votre feedback a été enregistré avec succès.'
    else
      render :new
    end
  end
  def destroy
    @feedback.destroy
    redirect_to feedbacks_path, notice: 'Le feedback a été supprimé avec succès.'
  end

  private

  def feedback_params
    params.require(:feedback).permit(:question_1, :question_2, :question_3, :question_4, :question_5, :question_6, :question_7, :question_8, :question_9, :question_10, :question_11, :question_12)
  end
  def check_feedback_submission
    if Feedback.exists?(user_id: current_user.id)
      redirect_to root_path, alert: 'Vous avez déjà soumis un feedback.'
    end
  end
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end
end
