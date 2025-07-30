module Api
  module V1
    class RejectedOeuvresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_rejected_oeuvre, only: [:show, :update, :destroy]

      def index
        @rejected_oeuvres = Rejected_oeuvre.all
        render json: @rejected_oeuvres
      end

      def show
        render json: @rejected_oeuvre
      end

      def create
        @rejected_oeuvre = Rejected_oeuvre.new(rejected_oeuvre_params)
        if @rejected_oeuvre.save
          render json: @rejected_oeuvre, status: :created
        else
          render json: @rejected_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def update
        if @rejected_oeuvre.update(rejected_oeuvre_params)
          render json: @rejected_oeuvre
        else
          render json: @rejected_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @rejected_oeuvre.destroy
        head :no_content
      end

      private

      def set_rejected_oeuvre
        @rejected_oeuvre = Rejected_oeuvre.find(params[:id])
      end

      def rejected_oeuvre_params
        params.require(:rejected_oeuvre).permit(:nom, :user_id, :reason)
      end
    end
  end
end
