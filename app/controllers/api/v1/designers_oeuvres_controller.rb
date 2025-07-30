module Api
  module V1
    class DesignersOeuvresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_designers_oeuvre, only: [:show, :update, :destroy]

      def index
        @designers_oeuvres = Designers_oeuvre.all
        render json: @designers_oeuvres
      end

      def show
        render json: @designers_oeuvre
      end

      def create
        @designers_oeuvre = Designers_oeuvre.new(designers_oeuvre_params)
        if @designers_oeuvre.save
          render json: @designers_oeuvre, status: :created
        else
          render json: @designers_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def update
        if @designers_oeuvre.update(designers_oeuvre_params)
          render json: @designers_oeuvre
        else
          render json: @designers_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @designers_oeuvre.destroy
        head :no_content
      end

      private

      def set_designers_oeuvre
        @designers_oeuvre = Designers_oeuvre.find(params[:id])
      end

      def designers_oeuvre_params
        params.require(:designers_oeuvre).permit(:designer_id, :oeuvre_id)
      end
    end
  end
end
