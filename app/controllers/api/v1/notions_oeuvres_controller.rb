module Api
  module V1
    class NotionsOeuvresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_notions_oeuvre, only: [:show, :update, :destroy]

      def index
        @notions_oeuvres = Notions_oeuvre.all
        render json: @notions_oeuvres
      end

      def show
        render json: @notions_oeuvre
      end

      def create
        @notions_oeuvre = Notions_oeuvre.new(notions_oeuvre_params)
        if @notions_oeuvre.save
          render json: @notions_oeuvre, status: :created
        else
          render json: @notions_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def update
        if @notions_oeuvre.update(notions_oeuvre_params)
          render json: @notions_oeuvre
        else
          render json: @notions_oeuvre.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @notions_oeuvre.destroy
        head :no_content
      end

      private

      def set_notions_oeuvre
        @notions_oeuvre = Notions_oeuvre.find(params[:id])
      end

      def notions_oeuvre_params
        params.require(:notions_oeuvre).permit(:oeuvre_id, :notion_id)
      end
    end
  end
end
