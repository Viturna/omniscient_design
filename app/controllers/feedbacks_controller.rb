class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :check_feedback_submission, only: [:new, :create]
  before_action :set_feedback, only: [:destroy]
  before_action :check_admin_role, only: [:index, :destroy]
  layout 'admin', only: [:index]

  def index
    @current_page = 'feedbacks'
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
    @feedback = current_user.feedbacks.build(feedback_params)

    if @feedback.save
      GamificationService.new(current_user).check_investigator
      notify_admins_of_new_feedback(@feedback)
      redirect_to root_path, notice: I18n.t('feedback.create.success')
    else
      flash.now[:alert] = I18n.t('feedback.create.failure')
      render :new
    end
  end

  def destroy
    @feedback.destroy
    redirect_to feedbacks_path, notice: I18n.t('feedback.destroy.success')
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :question_1, :question_2, :question_3, :question_4, :question_5, 
      :question_6, :question_7, :question_8, :question_9, :question_10, 
      :question_11, :question_12
    )
  end

  def check_feedback_submission
    if Feedback.exists?(user_id: current_user.id)
      redirect_to root_path, alert: I18n.t('feedback.already_submitted')
    end
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def notify_admins_of_new_feedback(feedback)
    submitter_name = feedback.user.pseudo || feedback.user.firstname
    title = "Nouveau Feedback"
    message = I18n.t('notifications.new_feedback', 
                     user_name: submitter_name, 
                     default: "Nouveau feedback reçu de #{submitter_name}")
    
    User.where(role: 'admin').each do |user| 
      Notification.create(
        user_id: user.id, 
        notifiable: feedback, 
        title: title,
        message: message,
        link: feedbacks_path,
        status: :unread
      )
    end
  rescue => e
    Rails.logger.error "ERREUR notify_admins_of_new_feedback: #{e.message}"
  end
end
