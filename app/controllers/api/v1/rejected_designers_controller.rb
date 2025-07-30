module Api
  module V1
    class RejectedDesignersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_rejected_designer, only: [:show, :update, :destroy]

      def index
        @rejected_designers = Rejected_designer.all
        render json: @rejected_designers
      end

      def show
        render json: @rejected_designer
      end

      def create
        @rejected_designer = Rejected_designer.new(rejected_designer_params)
        if @rejected_designer.save
          render json: @rejected_designer, status: :created
        else
          render json: @rejected_designer.errors, status: :unprocessable_entity
        end
      end

      def update
        if @rejected_designer.update(rejected_designer_params)
          render json: @rejected_designer
        else
          render json: @rejected_designer.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @rejected_designer.destroy
        head :no_content
      end

      private

      def set_rejected_designer
        @rejected_designer = Rejected_designer.find(params[:id])
      end

      def rejected_designer_params
        params.require(:rejected_designer).permit(:nom, :prenom, :user_id, :reason)
      end
    end
  end
end
