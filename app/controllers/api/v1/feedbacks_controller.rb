module Api
  module V1
    class FeedbacksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_feedback, only: [:show, :update, :destroy]

      def index
        @feedbacks = Feedback.all
        render json: @feedbacks
      end

      def show
        render json: @feedback
      end

      def create
        @feedback = Feedback.new(feedback_params)
        if @feedback.save
          render json: @feedback, status: :created
        else
          render json: @feedback.errors, status: :unprocessable_entity
        end
      end

      def update
        if @feedback.update(feedback_params)
          render json: @feedback
        else
          render json: @feedback.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @feedback.destroy
        head :no_content
      end

      private

      def set_feedback
        @feedback = Feedback.find(params[:id])
      end

      def feedback_params
        params.require(:feedback).permit(:user_id, :message, :email)
      end
    end
  end
end
